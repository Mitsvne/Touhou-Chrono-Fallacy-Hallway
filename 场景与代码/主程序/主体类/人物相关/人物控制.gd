extends Node
## 人物控制类：人物做出某些动作或效果的方法
class_name Character_Ctrler

@export var character:CharacterBody2D #角色节点
@export var character_data: Character_Data
@export var character_input: Character_Input
@export var anplayer: AnimationPlayer

var is_key_moving:bool=true  # 是否按键移动
var is_moving:bool=false  # 是否移动
var is_gravity:bool=false  # 是否受重力
var is_allow_behit:bool=true  # 是否可以受击
var is_invincible:bool=true  # 是否无敌
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float # 重力数值
var x_max_speed: float = 9999.0  # x轴最大速度
var y_max_speed: float = 9999.0  # y轴最大速度
var current_velocity: Vector2 = Vector2.ZERO  # 当前速度
var current_drag: Vector2 = Vector2.ZERO  # 当前阻力/加速度


func _ready() -> void:
	set_physics_process(false)
	print("3.Character_Ctrler初始化完成")
	pass

func _physics_process(delta: float) -> void:
	if not is_moving or not is_instance_valid(character):
		return
	if is_gravity:
		current_velocity.y += gravity * delta
	current_velocity = _update_velocity(current_velocity, current_drag, delta)
	current_velocity.x = clamp(current_velocity.x, -x_max_speed, x_max_speed)
	current_velocity.y = clamp(current_velocity.y, -y_max_speed, y_max_speed)
	var world_velocity = Vector2(current_velocity.x * character_data.direction, current_velocity.y)
	#print(world_velocity)
	if world_velocity.length() < 1.0:
		stop_move()
		return
	var movement = world_velocity * delta
	var collision := character.move_and_collide(movement)
	if collision:
		var normal := collision.get_normal()
		var velocity_dot_normal := world_velocity.dot(normal)
		if velocity_dot_normal < 0:
			world_velocity -= velocity_dot_normal * normal
		current_velocity = Vector2(world_velocity.x * character_data.direction, world_velocity.y)
		if current_velocity.length() < 1.0:
			stop_move()
			return

## 根据阻力和加速度更新速度,drag为正数时是阻力，为负数时是加速度
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

## 开始移动函数
func start_move(initial_velocity: Vector2 = Vector2.ZERO, drag: Vector2 = Vector2.ZERO):
	if is_moving:
		return
	current_velocity = initial_velocity
	current_drag = drag
	is_moving = true
	set_physics_process(true)

## 设置阻力/加速度函数
func set_drag(drag: Vector2):
	current_drag = drag

## 停止移动函数
func stop_move():
	is_moving = false
	current_drag = Vector2.ZERO
	current_velocity.x = 0
	if current_velocity.y < 0 and not is_gravity:
		current_velocity.y = 0
	set_physics_process(false)

## 是否在move移动中
func get_is_moving():
	return is_moving

## 设置按键移动
func set_key_move(value:bool):
	is_key_moving=value

## 是否可按键移动
func get_is_key_moving():
	return is_key_moving

## 获取移动方向
func get_move_direction():
	var move_dir = Input.get_vector(character_input.move_left,character_input.move_right,character_input.move_up, character_input.move_down)
	return move_dir

## 开始冲刺函数
func start_dash(speed: float = 0.0, drag: float = 0.0):
	var dash_dir = get_move_direction()
	if dash_dir == Vector2.ZERO:
		dash_dir=Vector2(1.0,0.0)
	var c_velocity = dash_dir.normalized() * speed
	var c_drag = Vector2(1.0,1.0).normalized() * drag
	start_move(c_velocity,c_drag)
	set_invincible(true)

## 停止冲刺函数
func stop_dash():
	stop_move()
	set_invincible(false)

## 是否启动重力
func apply_gravity(value:bool):
	is_gravity=value

## 设置朝向
func set_direction(value:int):
	character_data.direction=value

## 设置是否可以被打
func set_is_allow_behit(value:bool):
	is_allow_behit=value

## 获取是否可以被打
func get_is_allow_behit():
	return is_allow_behit

## 获取hurtbox
func _get_hurtbox():
	for child in owner.get_children():
		if child is Hurtbox:
			return child

## 获取hurtbox中所有的图形
func _get_collisionshapes() -> Array[CollisionShape2D]:
	var hurtbox: Hurtbox=_get_hurtbox()
	var shapes: Array[CollisionShape2D] = []
	for child in hurtbox.get_children():
		if child is CollisionShape2D:
			shapes.append(child)
	return shapes

## 设置是否无敌
func set_invincible(value:bool):
	is_invincible=value
	for shape in _get_collisionshapes():
		shape.set_deferred("disabled", value)

## 获取是否无敌
func get_invincible():
	return is_invincible

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

## 发射弹幕
func shoot(Bullet,offset:Vector2,offset_rotation:float=0.0,generate_position:Vector2=Vector2(0,0)):
	if not Bullet:
		return
	var bullet_instance = Bullet.instantiate()
	get_parent().add_child(bullet_instance)
	bullet_instance.add_to_group("bullets")
	bullet_instance.add_to_group(character_data.team)
	bullet_instance.bullet_data.bullet_team=character_data.team
	bullet_instance.bullet_data.bullet_owner=character
	bullet_instance.bullet_data.bullet_direction=character_data.direction
	#print("飞行物所在组：",bullet_instance.get_groups())
	#print("飞行物队伍："+bullet_instance.bullet_data.bullet_team)
	#print("飞行物主人：",bullet_instance.bullet_ctrler.bullet_owner)
	if generate_position.length()!=0:
		bullet_instance.position.x = generate_position.x + offset.x * character_data.direction
		bullet_instance.position.y = generate_position.y + offset.y
	else:
		bullet_instance.position.x = character.position.x + offset.x * character_data.direction
		bullet_instance.position.y = character.position.y + offset.y
	bullet_instance.rotation = character.rotation + deg_to_rad(offset_rotation)

## 添加道具
func add_prop(prop,offset:Vector2):
	if not prop:
		return
	var prop_instance = prop.instantiate()
	get_parent().add_child(prop_instance)
	prop_instance.add_to_group("props")
	prop_instance.add_to_group(character_data.team)
	prop_instance.prop_data.prop_team=character_data.team
	prop_instance.prop_data.prop_owner=character
	prop_instance.prop_data.prop_direction=character_data.direction
	#print("道具所在组：",prop_instance.get_groups())
	#print("道具队伍："+prop_instance.prop_data.bullet_team)
	#print("道具主人：",prop_instance.prop_data.prop_owner)
	prop_instance.position.x = character.position.x + offset.x * character_data.direction
	prop_instance.position.y = character.position.y + offset.y
	prop_instance.rotation = character.rotation

func add_warning_line(line,offset:Vector2,offset_rotation:float=0.0,generate_position:Vector2=Vector2(0,0)):
	if not line:
		return
	var line_instance = line.instantiate()
	get_parent().add_child(line_instance)
	if generate_position.length()!=0:
		line_instance.position.x = generate_position.x + offset.x * character_data.direction
		line_instance.position.y = generate_position.y + offset.y
	else:
		line_instance.position.x = character.position.x + offset.x * character_data.direction
		line_instance.position.y = character.position.y + offset.y
	line_instance.rotation = character.rotation + deg_to_rad(offset_rotation)

## 获取道具
func get_prop(pname:String):
	var props = get_tree().get_nodes_in_group("props")
	for prop in props:
		var prop_name=prop.prop_data.prop_name
		if prop_name and prop_name==pname:
			return prop
		else:
			printerr("未找到名为",pname,"的道具")

## 获取弹幕
func get_bullet(bname:String):
	var bullets = get_tree().get_nodes_in_group("bullets")
	for bullet in bullets:
		var bullet_name=bullet.bullet_data.bullet_name
		if bullet_name and bullet_name==bname:
			return bullet
		else:
			printerr("未找到名为",bname,"的弹幕")

## 获取对方
func get_Target():
	var team=character_data.team
	var characters = get_tree().get_nodes_in_group("characters")
	for _character in characters:
		if _character is CharacterBody2D and not _character.is_in_group(team):
			return _character
	return null

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
