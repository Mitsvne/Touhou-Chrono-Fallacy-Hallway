extends Node
class_name Bullet_Ctrler

@export var anplayer: AnimationPlayer
@export var bullet_data: Bullet_Data
@export var bullet: Node2D

## 弹幕运动模式(直线，追踪，自由飞行)
enum MovementMode { STRAIGHT, TRACKING, FREE_FLIGHT }
var current_mode: MovementMode = MovementMode.STRAIGHT
var is_moving: bool = false:                   # 是否移动
	set(v):
		is_moving = v
		set_physics_process(v)
var bullet_owner: CharacterBody2D              # 弹幕主人 
var tracking_target: Node2D                    # 追踪目标
var is_gravity: bool = false                   # 是否受重力
var gravity: float = ProjectSettings.get("physics/2d/default_gravity")
var gravity_scale: float = 1.0                 # 重力倍率
var velocity: Vector2 = Vector2.ZERO           # 速度
var drag_vec: Vector2 = Vector2.ZERO           # 直线模式：矢量阻力/加速度
var drag_scalar: float = 0.0                   # 追踪/自由飞行模式：标量阻力/加速度
var max_speed_vec: Vector2 = Vector2(9999.0, 9999.0)
var min_turn_radius: float = 200.0             # 追踪时的最小转弯半径，会因距离收紧而缩小
var tighten_speed: float = 0.5                 # 螺旋收紧速度
var tighten_progress: float = 0.0

const MIN_RADIUS_LIMIT: float = 10.0            # 最小转弯半径下限
const STOP_THRESHOLD_SQ: float = 1.0            # 停止速度阈值（平方）

func _ready() -> void:
	is_moving = false
	if not bullet_data or not bullet:
		push_error("Bullet_Ctrler: 依赖项缺失")
		return
	bullet_owner = bullet_data.bullet_owner

func _physics_process(delta: float) -> void:
	if not is_instance_valid(bullet):
		stop_move()
		return
	# 1. 处理重力
	if is_gravity:
		velocity.y += gravity * gravity_scale * delta
	# 2. 根据模式更新速度
	match current_mode:
		MovementMode.TRACKING:
			_process_tracking(delta)
		MovementMode.FREE_FLIGHT:
			_apply_scalar_drag(delta)
		MovementMode.STRAIGHT:
			_apply_vector_drag(delta)
	# 3. 限制速度
	velocity.x = clamp(velocity.x, -max_speed_vec.x, max_speed_vec.x)
	velocity.y = clamp(velocity.y, -max_speed_vec.y, max_speed_vec.y)
	# 4. 执行位移与旋转
	var world_vel = _to_world_velocity()
	if world_vel.length_squared() < STOP_THRESHOLD_SQ:
		stop_move()
		return
	bullet.rotation = world_vel.angle()
	bullet.global_position += world_vel * delta

## 追踪逻辑
func _process_tracking(delta: float) -> void:
	if not is_instance_valid(tracking_target):
		current_mode = MovementMode.FREE_FLIGHT
		return
	_apply_scalar_drag(delta)
	var cur_spd = velocity.length()
	if cur_spd < 0.1: return
	# 计算理想方向：直接使用世界坐标差，不要乘以 direction
	var to_target_vec = tracking_target.global_position - bullet.global_position
	var dist_sq = to_target_vec.length_squared()
	# 螺旋收紧逻辑
	if dist_sq < min_turn_radius * min_turn_radius:
		tighten_progress += delta * tighten_speed
	else:
		tighten_progress = move_toward(tighten_progress, 0.0, delta)
	var eff_radius = max(min_turn_radius / (1.0 + tighten_progress), MIN_RADIUS_LIMIT)
	# 转向限制
	var max_w = cur_spd / eff_radius
	# 计算世界坐标下的角度差
	var angle_diff = angle_difference(velocity.angle(), to_target_vec.angle())
	# 计算步进（注意这里的符号，angle_difference 是 目标 - 当前，所以直接加上步进即可）
	var step = clamp(angle_diff, -max_w * delta, max_w * delta)
	velocity = velocity.rotated(step)

## 标量阻力/加速度处理（追踪/自由飞行）
func _apply_scalar_drag(delta: float) -> void:
	var spd = velocity.length()
	if drag_scalar > 0:
		spd = move_toward(spd, 0.0, drag_scalar * delta)
	elif drag_scalar < 0:
		spd += abs(drag_scalar) * delta
	# 保证速度不为0以维持方向
	velocity = velocity.normalized() * max(spd, 1.0)

## 矢量阻力/加速度处理（直线模式）
func _apply_vector_drag(delta: float) -> void:
	# 优化：直接在原向量上操作
	velocity.x = _calculate_axis_drag(velocity.x, drag_vec.x, delta, bullet_data.direction)
	velocity.y = _calculate_axis_drag(velocity.y, drag_vec.y, delta, -1.0)

## 对单个轴的速度分量进行阻力/加速度更新
func _calculate_axis_drag(val: float, drag: float, delta: float, def_dir: float) -> float:
	if drag >= 0:
		return move_toward(val, 0.0, drag * delta)
	if is_zero_approx(val):
		return abs(drag) * delta * def_dir
	return val + sign(val) * abs(drag) * delta

## 内部速度与世界速度的转换
func _to_world_velocity() -> Vector2:
	# 只有在 STRAIGHT 模式下才应用方向镜像逻辑
	if current_mode == MovementMode.STRAIGHT:
		return Vector2(velocity.x * bullet_data.direction, velocity.y)
	return velocity

## 参数重置函数
func _reset_params() -> void:
	is_gravity = false
	gravity = ProjectSettings.get("physics/2d/default_gravity")
	gravity_scale = 1.0
	drag_vec = Vector2.ZERO
	drag_scalar = 0.0
	tighten_progress = 0.0
	tracking_target = null
	current_mode = MovementMode.STRAIGHT

## ---------------------------------开放的接口----------------------------------------

## 开始移动（直线模式）
func start_move(init_vel: Vector2, drag: Vector2 = Vector2.ZERO) -> void:
	velocity = init_vel
	drag_vec = drag
	current_mode = MovementMode.STRAIGHT
	is_moving = true

## 开始追踪
func start_track(target: Node2D, spd: float, drag: float = 0.0, radius: float = 400.0) -> void:
	if not is_instance_valid(target): return
	tracking_target = target
	drag_scalar = drag
	min_turn_radius = radius
	tighten_progress = 0.0
	# 重要：追踪模式运行在世界坐标系，不应受 direction 的镜像影响
	if is_moving and current_mode == MovementMode.STRAIGHT:
		# 从直线模式切过来，必须把带镜像的速度转回真实的世界速度
		velocity = _to_world_velocity()
	elif not is_moving:
		velocity = (target.global_position - bullet.global_position).normalized() * spd
	current_mode = MovementMode.TRACKING
	is_moving = true

## 沿自身当前角度飞行（进入直线或自由飞行模式）
func start_move_forward(speed: float, drag: float = 0.0, use_vector_drag: bool = false) -> void:
	if not is_instance_valid(bullet): return
	# 获取当前物体的全局朝向向量b
	#print("飞行物移动角度：",rad_to_deg(rotation))
	var direction = Vector2.RIGHT.rotated(bullet.global_rotation)
	var init_velocity = direction * speed
	if use_vector_drag:
		# 如果使用矢量阻力，需要考虑 direction 镜像（直线模式）
		# 这里的处理是为了抵消 _to_world_velocity 中的镜像，确保方向正确
		init_velocity.x /= bullet_data.direction
		start_move(init_velocity, Vector2(drag, drag))
	else:
		# 否则进入自由飞行模式（标量阻力，不考虑镜像）
		velocity = init_velocity
		drag_scalar = drag
		current_mode = MovementMode.FREE_FLIGHT
		is_moving = true

## 直线追踪（发射时锁定方向，带角度限制）
func start_move_towards(target_pos: Vector2, speed: float, drag: float = 0.0,
		min_angle: float = -INF, max_angle: float = INF,
		base_direction: Vector2 = Vector2.RIGHT) -> void:
	if not is_instance_valid(bullet):
		return
	if not target_pos:
		printerr("目标位置为空")
		return
	var to_target = target_pos - bullet.global_position
	if to_target.is_zero_approx(): return
	# 1. 获取当前逻辑朝向 (1 或 -1)
	var face_dir = bullet_data.direction
	# 2. 修正基准方向：如果朝左，基准方向也需要镜像
	# 比如默认基准是 Vector2.RIGHT，朝左时逻辑基准变为 Vector2.LEFT
	var effective_base_dir = base_direction
	effective_base_dir.x *= face_dir
	# 3. 计算角度差
	var base_angle = effective_base_dir.angle()
	var target_angle = to_target.angle()
	var angle_diff = angle_difference(base_angle, target_angle)
	# 4. 限制角度
	# 注意：当朝向为左(-1)时，angle_difference 的正负号逻辑依然适用，
	# 向上依然是负角度差（在 Godot 坐标系中），向下依然是正。
	angle_diff = clamp(angle_diff, deg_to_rad(min_angle), deg_to_rad(max_angle))
	# 5. 生成最终世界坐标系下的发射速度
	var final_angle = base_angle + angle_diff
	var final_vel = Vector2.RIGHT.rotated(final_angle) * speed
	# 6. 转换为内部速度 (抵消 _to_world_velocity 的镜像影响)
	# 这样在 _to_world_velocity 再次乘以 face_dir 时，结果会变回 final_vel
	final_vel.x /= face_dir
	start_move(final_vel, Vector2(drag, drag))

## 抛物线移动：给定目标位置和弧顶高度，自动计算初速度
func start_move_parabola(target_pos: Vector2, speed: float = 0.0, arc_height: float = 100.0, drag: float = 0.0) -> void:
	if not is_instance_valid(bullet): return
	# 1. 状态初始化
	_reset_params()
	is_gravity = true
	drag_scalar = drag
	current_mode = MovementMode.FREE_FLIGHT # 抛物线通常使用自由飞行模式以支持标量阻力
	var diff = target_pos - bullet.global_position
	var v_x: float = 0.0
	var v_y: float = 0.0
	if is_zero_approx(speed):
		# --- 模式 A：自动计算模式（基于高度确定初速度） ---
		var g = gravity
		var arc_h = max(arc_height, 0.01)   # 防止除零
		# 上升阶段
		var v_y_up = -sqrt(2 * g * arc_h)   # 向上为负
		var t_up = -v_y_up / g              # 到达最高点的时间
		# 下降阶段：从最高点 (-arc_h) 落到目标 Y (diff.y)
		var drop_distance = arc_h + diff.y  # diff.y 可正可负
		if drop_distance < 0:
			arc_h = -diff.y + 10.0
			v_y_up = -sqrt(2 * g * arc_h)
			t_up = -v_y_up / g
			drop_distance = arc_h + diff.y
		var t_down = sqrt(2 * drop_distance / g)
		var t_total = t_up + t_down
		v_y = v_y_up
		v_x = diff.x / t_total
	else:
		 # --- 模式 B：固定速率模式 ---
		var g = gravity
		var x = diff.x
		var y = diff.y
		var s = speed
		var discriminant = pow(s, 4) - g * (g * x * x + 2 * y * s * s)
		if discriminant < 0:
			# 无法到达，回退到 45° 角（或选择最大射程角）
			var angle = deg_to_rad(45)
			if x < 0: angle = PI - angle
			velocity = Vector2(cos(angle), -sin(angle)) * s
		else:
			var root = sqrt(discriminant)
			# 取较高的弧线（正切值较小的解），更接近“抛物线感”
			var tan_theta = (s * s - root) / (g * x)   # 高弧解
			var angle = atan(tan_theta)
			if x < 0: angle += PI
			velocity = Vector2(cos(angle), -sin(angle)) * s
	# 2. 启动
	if is_zero_approx(v_x) and is_zero_approx(v_y):
		# 如果使用了模式B计算出的 velocity，直接应用
		pass
	else:
		velocity = Vector2(v_x, v_y)
	is_moving = true

## 停止追踪模式进入自由飞行模式
func stop_track() -> void:
	if current_mode == MovementMode.TRACKING:
		current_mode = MovementMode.FREE_FLIGHT

## 停止所有模式移动
func stop_move() -> void:
	is_moving = false
	velocity = Vector2.ZERO
	_reset_params()

## 直线模式：设置矢量阻力/加速度
func set_drag_vec(value:Vector2):
	drag_vec=value
	
## 追踪/自由飞行模式：设置标量阻力/加速度
func set_drag_scalar(value:float):
	drag_scalar=value

## 是否启动重力
func apply_gravity(value: bool):
	is_gravity = value

## 设置朝向（1=右，-1=左）
func set_direction(value: int):
	bullet_data.direction = value
	bullet.scale.x=value

## 获取场景内的物理碰撞层
func get_all_collision_shapes(root: Node) -> Array[Node]:
	var shapes: Array[Node] = []
	shapes.append_array(root.find_children("*", "CollisionShape2D"))
	shapes.append_array(root.find_children("*", "CollisionPolygon2D"))
	return shapes

## 获取场景内的图像节点
func get_all_visual_nodes(root: Node) -> Array[Node]:
	var visuals: Array[Node] = []
	visuals.append_array(root.find_children("*", "Sprite2D"))
	visuals.append_array(root.find_children("*", "AnimatedSprite2D"))
	return visuals

## 检查是否有物理碰撞层负缩放
func check_collision_negative_scale(root: Node) -> void:
	var shapes = get_all_collision_shapes(root)
	for shape in shapes:
		var global_scale = shape.global_transform.get_scale()
		if global_scale.x < 0 or global_scale.y < 0:
			print("[警告] 负缩放碰撞体: ", shape.get_path(), " scale=", global_scale)

## 镜像效果
func initialize_mirror(dir: int):
	if dir == 1:
		return
	var collisions=get_all_collision_shapes(bullet)
	var sprites=get_all_visual_nodes(bullet)
	check_collision_negative_scale(bullet)
	# 1. 贴图镜像
	if sprites: 
		for sprite in sprites:
			#sprite.position *= -1 
			sprite.flip_v = true
	# 2. 物理碰撞体局部位置镜像
	if collisions:
		for collision in collisions:
			collision.position.x *= -1
			#collision.position.x *= -1
			#print(collision)

## 发射弹幕
func shoot(Bullet,offset:Vector2,offset_rotation:float=0.0,generate_position:Vector2=Vector2(0,0)):
	if not Bullet:
		return
	var bullet_instance = Bullet.instantiate()
	get_parent().add_child(bullet_instance)
	bullet_instance.add_to_group("bullets")
	bullet_instance.add_to_group(bullet_data.team)
	bullet_instance.bullet_data.bullet_team=bullet_data.team
	bullet_instance.bullet_data.bullet_owner=bullet
	bullet_instance.bullet_data.direction=bullet_data.direction
	#位置偏移
	var origin = generate_position if generate_position.length() != 0 else bullet.global_position
	bullet_instance.global_position.x = origin.x + offset.x * bullet_data.direction
	bullet_instance.global_position.y = origin.y + offset.y
	#飞行物根据朝向镜像
	bullet_instance.bullet_ctrler.initialize_mirror(bullet_data.direction)
	if bullet_data.direction == 1:
		bullet_instance.rotation = deg_to_rad(offset_rotation)
	else:
		bullet_instance.rotation = PI - deg_to_rad(offset_rotation)

## 获取敌人节点
func get_target():
	var team = bullet_data.team
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character is CharacterBody2D and not character.is_in_group(team):
			return character
	return null

## 跳转到动画的指定时间点（秒）
func jump_to_time(anim_name: String, time: float, play_after: bool = true) -> void:
	if not anplayer.has_animation(anim_name):
		print("错误：动画 '", anim_name, "' 不存在。")
		return
	var anim = anplayer.get_animation(anim_name)
	time = clamp(time, 0, anim.length) #防止time超出上限
	anplayer.play(anim_name)
	anplayer.seek(time, true)
	if not play_after:
		anplayer.pause()

## 跳转到动画的指定帧（需提供动画的帧率）
func jump_to_frame(anim_name: String, frame: int, fps: float = 30.0, play_after: bool = true) -> void:
	var time = frame / fps
	jump_to_time(anim_name, time, play_after)


## 设置box
func disable_box(box:Area2D,value:bool):
	for i in box.get_children():
		if i is CollisionShape2D:
			i.set_deferred("disabled", value)

func play_audio(audio_path: NodePath, type: String = "SFX"):
	var audio_node = get_node(audio_path)
	var stream = audio_node.stream
	if type == "BGM":
		AudioManager.play_bgm(stream)
	elif type == "SFX":
		AudioManager.play_sfx(stream)
	elif type == "Voice":
		AudioManager.play_voice(stream)
	
