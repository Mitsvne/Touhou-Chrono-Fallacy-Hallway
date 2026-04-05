extends Node
class_name Bullet_Ctrler

@export var bullet:Area2D
var bullet_owner:CharacterBody2D
var bullet_team:String
var bullet_direction:float
var is_moving:bool=false  # 是否移动
var is_gravity:bool=false  # 是否受重力
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float # 重力数值
var x_max_speed: float = 99999.0  # x轴最大速度
var y_max_speed: float = 99999.0  # y轴最大速度
var current_velocity: Vector2 = Vector2.ZERO  # 当前速度
var current_drag: Vector2 = Vector2.ZERO  # 当前阻力/加速度
var motion_ray: RayCast2D


func _ready() -> void:
	await get_tree().process_frame #等一帧，其他类初始完成
	#print(bullet_owner,bullet_team)
	pass # Replace with function body.


func _process(_delta: float) -> void:
	pass

##私有：根据阻力和加速度更新速度,drag为正数时是阻力，为负数时是加速度
func _update_velocity(velocity: Vector2, drag: Vector2, delta: float) -> Vector2:
	if drag.x >= 0:
		velocity.x = move_toward(velocity.x, 0, drag.x * delta)
	else:
		velocity.x += sign(velocity.x) * abs(drag.x) * delta if velocity.x != 0 else 0
	if drag.y >= 0:
		velocity.y = move_toward(velocity.y, 0, drag.y * delta)
	else:
		velocity.y += sign(velocity.y) * abs(drag.y) * delta if velocity.y != 0 else 0
	return velocity

##私有：持续移动
func _move_loop():
	while is_moving and is_instance_valid(self) and is_instance_valid(bullet):
		var delta = get_process_delta_time()
		if is_gravity:
			current_velocity.y += gravity * delta
		current_velocity = _update_velocity(current_velocity, current_drag, delta)
		current_velocity.x = clamp(current_velocity.x, -x_max_speed, x_max_speed)
		current_velocity.y = clamp(current_velocity.y, -y_max_speed, y_max_speed)
		var world_velocity = Vector2(current_velocity.x * bullet_direction, current_velocity.y)
		if world_velocity.length() < 1:
			stop_move()
			break
		bullet.position += world_velocity * delta
		#print("当前速度：%s，阻力/加速度:%s"%[current_velocity,current_drag])
		await get_tree().process_frame
	current_velocity = Vector2.ZERO
	current_drag = Vector2.ZERO


##开始移动函数
func start_move(initial_velocity: Vector2 = Vector2.ZERO, drag: Vector2 = Vector2.ZERO):
	if is_moving:
		return
	current_velocity = initial_velocity
	current_drag = drag
	is_moving = true
	_move_loop()

##设置阻力/加速度函数
func set_drag(drag: Vector2):
	current_drag = drag

##停止移动函数
func stop_move():
	is_moving=false
	current_drag=Vector2.ZERO
	current_velocity.x = 0
	if current_velocity.y<0 and not is_gravity:
		current_velocity.y = 0
