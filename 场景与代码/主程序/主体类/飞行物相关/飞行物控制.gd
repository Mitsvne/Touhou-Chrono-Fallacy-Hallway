extends Node
class_name Bullet_Ctrler

@export var anplayer: AnimationPlayer
@export var bullet_data: Bullet_Data
@export var bullet: Node2D

## 弹幕运动模式(直线，追踪，自由角度飞行)
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
var velocity: Vector2 = Vector2.ZERO           # 速度
var drag_vec: Vector2 = Vector2.ZERO           # 直线模式矢量阻力/加速度
var drag_scalar: float = 0.0                   # 追踪/自由模式标量阻力
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
		velocity.y += gravity * delta
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
	# 处理标量速度增减
	_apply_scalar_drag(delta)
	var cur_spd = velocity.length()
	if cur_spd < 0.1: return
	# 计算理想角度
	var to_target = (tracking_target.global_position - bullet.global_position)*bullet_data.bullet_direction
	var dist_sq = to_target.length_squared()
	# 螺旋收紧逻辑
	if dist_sq < min_turn_radius * min_turn_radius:
		tighten_progress += delta * tighten_speed
	else:
		tighten_progress = move_toward(tighten_progress, 0.0, delta)
	var eff_radius = max(min_turn_radius / (1.0 + tighten_progress), MIN_RADIUS_LIMIT)
	# 转向限制：角速度 ω = v / r
	var max_w = cur_spd / eff_radius
	var angle_diff = angle_difference(velocity.angle(), to_target.angle())
	var step = clamp(-angle_diff, -max_w * delta, max_w * delta)
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
	velocity.x = _calculate_axis_drag(velocity.x, drag_vec.x, delta, bullet_data.bullet_direction)
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
		return Vector2(velocity.x * bullet_data.bullet_direction, velocity.y)
	return velocity

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
	# 如果是从直线模式切过来，转换当前速度到世界坐标系
	if is_moving and current_mode == MovementMode.STRAIGHT:
		velocity = _to_world_velocity()
	elif not is_moving:
		velocity = (target.global_position - bullet.global_position).normalized() * spd
	current_mode = MovementMode.TRACKING
	is_moving = true

## 沿自身当前角度飞行（进入直线或自由飞行模式）
func start_move_forward(speed: float, drag: float = 0.0, use_vector_drag: bool = false) -> void:
	if not is_instance_valid(bullet): return
	# 获取当前物体的全局朝向向量
	var direction = Vector2.RIGHT.rotated(bullet.global_rotation)*bullet_data.bullet_direction
	var init_velocity = direction * speed
	if use_vector_drag:
		# 如果使用矢量阻力，需要考虑 bullet_direction 镜像（直线模式）
		# 这里的处理是为了抵消 _to_world_velocity 中的镜像，确保方向正确
		init_velocity.x /= bullet_data.bullet_direction
		start_move(init_velocity, Vector2(drag, drag))
	else:
		# 否则进入自由飞行模式（标量阻力，不考虑镜像）
		velocity = init_velocity
		drag_scalar = drag
		current_mode = MovementMode.FREE_FLIGHT
		is_moving = true

## 直线追踪（发射时锁定方向，带角度限制）
func start_move_towards(target: Node2D, speed: float, drag: float = 0.0,
		min_angle: float = -INF, max_angle: float = INF,
		base_direction: Vector2 = Vector2.RIGHT) -> void:
	if not is_instance_valid(bullet) or not is_instance_valid(target):
		return
	var to_target = target.global_position - bullet.global_position
	if to_target.is_zero_approx(): return
	# 1. 计算目标相对于基准方向的角度差
	var base_angle = base_direction.angle()
	var target_angle = to_target.angle()
	var angle_diff = angle_difference(base_angle, target_angle)
	# 2. 限制在弧度区间内
	angle_diff = clamp(angle_diff, min_angle, max_angle)
	# 3. 生成最终发射速度
	var final_angle = base_angle + angle_diff
	var final_vel = Vector2.RIGHT.rotated(final_angle) * speed
	# 4. 转换为内部直线模式速度 (抵消 _to_world_velocity 的镜像影响)
	final_vel.x /= bullet_data.bullet_direction
	start_move(final_vel, Vector2(drag, drag))

## 停止追踪模式进入自由飞行模式
func stop_track() -> void:
	if current_mode == MovementMode.TRACKING:
		current_mode = MovementMode.FREE_FLIGHT

## 停止所有模式移动
func stop_move() -> void:
	is_moving = false
	velocity = Vector2.ZERO
	tracking_target = null

## 是否启动重力
func apply_gravity(value: bool):
	is_gravity = value

## 设置朝向（1=右，-1=左）
func set_direction(value: int):
	bullet_data.bullet_direction = value
	bullet.scale.x=value

## 获取敌人节点
func get_target():
	var team = bullet_data.bullet_team
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
	anplayer.play(anim_name)
	anplayer.seek(time, true)
	if not play_after:
		anplayer.pause()

## 跳转到动画的指定帧（需提供动画的帧率）
func jump_to_frame(anim_name: String, frame: int, fps: float = 30.0, play_after: bool = true) -> void:
	var time = frame / fps
	jump_to_time(anim_name, time, play_after)

## 播放音频
func play_audio(audio_path: NodePath):
	var audio_node = get_node(audio_path)
	if audio_node == null:
		printerr("找不到节点: ", audio_path)
		return
	if audio_node is AudioStreamPlayer:
		audio_node.play()
	else:
		printerr("该节点不是AudioStreamPlayer")
