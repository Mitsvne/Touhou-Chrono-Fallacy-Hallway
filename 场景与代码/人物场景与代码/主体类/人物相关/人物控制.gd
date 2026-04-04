extends Node
class_name Character_Ctrler
@export var character:CharacterBody2D #角色节点
@export var character_data: Character_Data
@export var character_input: Character_Input

var is_moving:bool=false  # 是否移动
var is_gravity:bool=false  # 是否受重力
var is_allow_behit:bool=true  # 是否可以受击
var is_invincible:bool=true  # 是否无敌
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float # 重力数值
var x_max_speed: float = 99999.0  # x轴最大速度
var y_max_speed: float = 99999.0  # y轴最大速度
var current_velocity: Vector2 = Vector2.ZERO  # 当前速度
var current_drag: Vector2 = Vector2.ZERO  # 当前阻力/加速度
var motion_ray: RayCast2D

func _ready() -> void:
	_create_motion_ray()
	print("Character_Ctrler初始化完成")
	pass

func _physics_process(_delta: float) -> void:
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
	while is_moving and is_instance_valid(self) and is_instance_valid(character):
		var delta = get_process_delta_time()
		if is_gravity:
			current_velocity.y += gravity * delta
		current_velocity = _update_velocity(current_velocity, current_drag, delta)
		current_velocity.x = clamp(current_velocity.x, -x_max_speed, x_max_speed)
		current_velocity.y = clamp(current_velocity.y, -y_max_speed, y_max_speed)
		var world_velocity = Vector2(current_velocity.x * character_data.direction, current_velocity.y)
		if world_velocity.length() < 1:
			stop_move()
			break
		var movement = world_velocity * delta
		# ---- 射线防穿透检测----
		if movement.length() > 0:
			motion_ray.target_position = movement
			motion_ray.force_raycast_update()
			if motion_ray.is_colliding():
				var collision_point = motion_ray.get_collision_point()  # 全局坐标
				var collision_normal = motion_ray.get_collision_normal()
				# 计算新位置：碰撞点往回退一小段距离（全局坐标）
				var new_global_pos = collision_point - movement.normalized() * 1.0
				character.global_position = new_global_pos
				# 根据碰撞法线调整速度（取消法线方向的分量，保留切向）
				if collision_normal.length() > 0:
					var velocity_dot_normal = current_velocity.dot(collision_normal)
					if velocity_dot_normal < 0:  # 只有朝向法线方向的速度才需要取消
						current_velocity -= velocity_dot_normal * collision_normal
				# 如果速度几乎为零，停止移动循环awdaw
				if current_velocity.length() < 1:
					stop_move()
					break
				# 注意：不跳出循环，而是继续下一帧（速度可能还有切向分量）
			else:
				character.global_position += movement
		else:
			character.global_position += movement
		await get_tree().process_frame
	current_velocity = Vector2.ZERO
	current_drag = Vector2.ZERO

##移动方向
func _move_direction():
	var move_dir = Input.get_vector(character_input.move_left,character_input.move_right,character_input.move_up, character_input.move_down)
	return move_dir

##创建运动射线
func _create_motion_ray():
	motion_ray = RayCast2D.new()
	motion_ray.name = "MotionRay"
	motion_ray.enabled = true
	motion_ray.hit_from_inside = true
	motion_ray.target_position = Vector2(1000, 0)
	motion_ray.collision_mask = character.collision_mask
	character.add_child.call_deferred(motion_ray)

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

##是否在move移动中
func get_is_moving():
	return is_moving

##开始冲刺函数
func start_dash(speed: float = 0.0, drag: float = 0.0):
	var dash_dir = _move_direction()
	if dash_dir == Vector2.ZERO:
		dash_dir=Vector2(1.0,0.0)
	var c_velocity = dash_dir.normalized() * speed
	var c_drag = Vector2(1.0,1.0).normalized() * drag
	#print(c_velocity,c_drag)
	start_move(c_velocity,c_drag)

##停止冲刺函数
func stop_dash():
	stop_move()

##是否启动重力
func apply_gravity(value:bool):
	is_gravity=value

##设置朝向
func set_direction(value:int):
	character_data.direction=value

##设置是否可以被打
func set_is_allow_behit(value:bool):
	is_allow_behit=value

##获取是否可以被打
func get_is_allow_behit():
	return is_allow_behit

##获取hurtbox
func _get_hurtbox():
	for child in owner.get_children():
		if child is Hurtbox:
			return child

##获取hurtbox中所有的图形
func _get_collisionshapes() -> Array[CollisionShape2D]:
	var hurtbox: Hurtbox=_get_hurtbox()
	var shapes: Array[CollisionShape2D] = []
	for child in hurtbox.get_children():
		if child is CollisionShape2D:
			shapes.append(child)
	return shapes

##设置是否无敌
func set_invincible(value:bool):
	is_invincible=value
	for shape in _get_collisionshapes():
		shape.set_deferred("disabled", value)

##获取是否可以被打
func get_invincible():
	return is_invincible

##发射弹幕函数
func shoot(Bullet,offset:Vector2):
	if not Bullet:
		return
	var bullet_instance = Bullet.instantiate()
	# 将子弹添加到当前场景的父节点下，使其独立于人物移动
	get_parent().add_child(bullet_instance)
	#子弹队伍设置为主人所在的队伍
	bullet_instance.team=owner.team
	bullet_instance.add_to_group(owner.team)
	#print("飞行物队伍："+bullet_instance.team)
	#print("飞行物所在组：",bullet_instance.get_groups())
	# 设置子弹的初始位置为人物当前位置
	bullet_instance.position = character.position + offset
	# 设置子弹的旋转方向为人物面向的方向
	bullet_instance.rotation = character.rotation
	# 根据人物方向调整子弹速度向量
	bullet_instance.velocity = bullet_instance.velocity.rotated(character.rotation)
