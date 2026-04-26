extends Node
class_name Bullet_Ctrler

@export var anplayer: AnimationPlayer
@export var bullet_data: Bullet_Data
@export var bullet: Area2D

var bullet_owner: CharacterBody2D              # 弹幕主人
var is_moving: bool = false                    # 是否移动
var is_gravity: bool = false                   # 是否受重力
var gravity: float = ProjectSettings.get("physics/2d/default_gravity")  # 重力数值
var x_max_speed: float = 9999.0                # x轴最大速度
var y_max_speed: float = 9999.0                # y轴最大速度
var current_velocity: Vector2 = Vector2.ZERO   # 当前速度
var current_drag: Vector2 = Vector2.ZERO       # 当前阻力/加速度

var tracking_target: CharacterBody2D       # 追踪目标
var is_tracking: bool = false              # 是否追踪
var use_free_flight: bool = false          # 停止追踪后是否进入自由飞行模式
var current_track_speed: float = 0.0        # 当前追踪速度
var current_tracking_drag: float = 0.0     # 当前追踪的阻力（正）或加速度（负）
var current_min_turn_radius: float = 200.0 # 最小转弯半径
var tighten_progress: float = 0.0          # 螺旋收紧进度
var current_tighten_speed: float = 0.5     # 收紧速度（越大缩小越快）

func _ready() -> void:
	set_physics_process(false)
	if not bullet_data:
		push_error("Bullet_Ctrler: bullet_data 未设置！")
		return
	if not bullet:
		push_error("Bullet_Ctrler: bullet 节点未赋值！")
		return
	bullet_owner=bullet_data.bullet_owner	

func _physics_process(delta: float) -> void:
	if not is_moving:
		set_physics_process(false)
		return
	if not is_instance_valid(bullet):
		stop_move()
		return
	# 重力
	if is_gravity:
		current_velocity.y += gravity * delta
	# 模式分支
	if is_tracking and is_instance_valid(tracking_target):
		# 追踪模式
		current_velocity = _compute_tracking_velocity(delta)
	elif use_free_flight:
		# 自由飞行也应用阻力/加速度（不重置为恒速）
		current_velocity = _update_track_velocity(current_velocity, current_tracking_drag, delta, false)
	else:
		# 普通直线模式
		current_velocity = _update_velocity(current_velocity, current_drag, delta)
	# 限速（使用两轴较大的值作为最大允许速率，防止单轴拖慢整体）
	var max_speed = max(x_max_speed, y_max_speed)
	if current_velocity.length() > max_speed:
		current_velocity = current_velocity.normalized() * max_speed
	# 转换为世界速度
	var world_velocity := _get_world_velocity()
	if world_velocity.length_squared() < 1.0:
		stop_move()
		return
	# 统一旋转与移动（旋转完全由速度方向决定，不再使用scale翻转）
	bullet.rotation = world_velocity.angle()
	bullet.position += world_velocity * delta

## 根据当前模式把内部速度转为世界速度
func _get_world_velocity() -> Vector2:
	if is_tracking or use_free_flight:
		return current_velocity
	else:
		return Vector2(current_velocity.x * bullet_data.bullet_direction, current_velocity.y)

## 计算追踪模式下的转向方向，返回基础速度向量
func _compute_tracking_velocity(delta: float) -> Vector2:
	# 1. 先根据阻力/加速度调整速度大小
	var vel = _update_track_velocity(current_velocity,current_tracking_drag,delta)
	var spd = vel.length()
	# 2. 用调整后的速度长度计算转向
	var to_target = tracking_target.global_position - bullet.global_position
	var distance_to_target = to_target.length()
	var desired_angle = to_target.angle()
	var current_angle = vel.angle()
	# 螺旋收紧
	if distance_to_target < current_min_turn_radius:
		tighten_progress += delta * current_tighten_speed
	else:
		tighten_progress = 0.0
	var effective_radius = current_min_turn_radius / (1.0 + tighten_progress)
	effective_radius = max(effective_radius, 4.0)
	var max_angle_per_sec = spd / effective_radius
	var max_delta_angle = max_angle_per_sec * delta
	var new_angle = lerp_angle(current_angle, desired_angle, max_delta_angle)
	return Vector2.RIGHT.rotated(new_angle) * spd

## 根据阻力和加速度更新追踪和自由飞行速度，drag为正数时是阻力，为负数时是加速度
func _update_track_velocity(vel: Vector2, drag: float, delta: float, reset_to_track_speed: bool = true) -> Vector2:
	var spd = vel.length()
	if drag > 0:
		spd = move_toward(spd, 0.0, drag * delta)
	elif drag < 0:
		spd += abs(drag) * delta
	else:
		if reset_to_track_speed:
			spd = current_track_speed
		# 否则保持原速度不变（自由飞行模式）
	spd = max(spd, 1.0)
	if spd == 1.0 and vel.length_squared() == 0.0:
		return vel  # 避免除零
	return vel.normalized() * spd

## 根据阻力和加速度更新速度，drag为正数时是阻力，为负数时是加速度
func _update_velocity(velocity: Vector2, drag: Vector2, delta: float) -> Vector2:
	var new_vel = velocity
	if drag.x >= 0:
		new_vel.x = move_toward(new_vel.x, 0, drag.x * delta)
	else:
		if new_vel.x != 0:
			new_vel.x += sign(new_vel.x) * abs(drag.x) * delta
	if drag.y >= 0:
		new_vel.y = move_toward(new_vel.y, 0, drag.y * delta)
	else:
		if new_vel.y != 0:
			new_vel.y += sign(new_vel.y) * abs(drag.y) * delta
	return new_vel

## 开始移动函数
func start_move(initial_velocity: Vector2 = Vector2.ZERO, drag: Vector2 = Vector2.ZERO):
	if is_moving:
		return
	current_velocity = initial_velocity
	current_drag = drag
	is_moving = true
	set_physics_process(true)

## 停止移动函数
func stop_move():
	if not is_moving:
		return
	is_moving = false
	set_physics_process(false)
	# 重置普通模式状态
	current_drag = Vector2.ZERO
	current_velocity.x = 0
	if current_velocity.y < 0 and not is_gravity:
		current_velocity.y = 0
	# 重置追踪/自由飞行状态
	is_tracking = false
	use_free_flight = false
	tracking_target = null
	tighten_progress = 0.0

## 设置阻力/加速度函数
func set_drag(drag: Vector2):
	current_drag = drag
'''
## 直线追踪函数
func start_move_towards(target: Node2D,speed: float, drag: float = 0.0):
	if not bullet: return
	var dir = (target.global_position - bullet.global_position).normalized()
	var desired = dir * speed
	var init_x = desired.x * bullet_data.bullet_direction
	var init_y = desired.y
	start_move(Vector2(init_x, init_y), Vector2(drag, drag))'''
## 直线追踪函数
func start_move_towards(target: Node2D,speed: float,drag: float = 0.0,min_angle: float = -INF,max_angle: float = INF,base_direction: Vector2 = Vector2.RIGHT):
	if not bullet: return
	if min_angle >= max_angle:
		var v = base_direction * speed
		start_move(v, Vector2(drag, drag))
		return
	var to_target = target.global_position - bullet.global_position
	if to_target.length_squared() < 0.0001:
		return
	var base_dir = base_direction.normalized()
	var target_dir = to_target.normalized()
	var base_angle = base_dir.angle()
	var target_angle = target_dir.angle()
	var diff = target_angle - base_angle
	if diff > PI: diff -= 2*PI
	elif diff < -PI: diff += 2*PI
	diff = clamp(diff, min_angle, max_angle)
	var final_angle = base_angle + diff
	var final_velocity = Vector2.RIGHT.rotated(final_angle) * speed
	start_move(final_velocity, Vector2(drag, drag))

## 沿自身角度（前方）飞行
func start_move_forward(speed: float, drag: float = 0.0):
	if not bullet:
		return
	# 1. 根据子弹当前旋转角度构造世界方向向量
	var dir = Vector2.RIGHT.rotated(bullet.rotation)*bullet_data.bullet_direction
	current_velocity = dir * speed
	# 2. 切换到自由飞行模式（不受 bullet_direction 翻转影响）
	is_tracking = false
	use_free_flight = true
	# 3. 设置标量阻力/加速度（自由飞行分支会用到）
	current_tracking_drag = drag
	# 4. 启动移动（如果尚未移动）
	if not is_moving:
		is_moving = true
		set_physics_process(true)

## 开始追踪函数
func start_track(target: Node, track_speed: float = 100, track_drag: float = 0.0, min_turn_radius: float = 400.0, tighten_spd: float = 0.5):
	if not is_instance_valid(target):
		return
	if not is_moving:
		var dir_to_target = (target.global_position - bullet.global_position).normalized()
		start_move(dir_to_target * track_speed)
	else:
		current_velocity = Vector2(current_velocity.x * bullet_data.bullet_direction, current_velocity.y)
	tracking_target = target
	current_track_speed = track_speed
	current_tracking_drag = track_drag
	current_min_turn_radius = min_turn_radius
	current_tighten_speed = tighten_spd
	tighten_progress = 0.0
	is_tracking = true
	use_free_flight = false

## 结束追踪函数
func stop_track():
	is_tracking = false
	tracking_target = null
	use_free_flight = true

## 设置追踪参数
func set_track(track_speed:float,track_drag:float,min_turn_radius: float, tighten_spd: float):
	current_track_speed=track_speed
	current_tracking_drag=track_drag
	current_min_turn_radius=min_turn_radius
	current_tighten_speed=tighten_spd

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
