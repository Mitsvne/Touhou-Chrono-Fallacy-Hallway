extends Node
## 人物控制类：人物做出某些动作或效果的方法
class_name Character_Ctrler

@export var character:CharacterBody2D #角色节点
@export var character_data: Character_Data
@export var anplayer: AnimationPlayer
@export var warning_line:PackedScene

var is_key_moving:bool=true  # 是否按键移动
var is_moving:bool=false  # 是否移动
var is_gravity:bool=false  # 是否受重力
var is_allow_behit:bool=true  # 是否可以受击
var is_allow_losehp:bool=true  # 是否可以受击
var is_penetrate:bool=true  # 是否可被穿透
var is_invincible:bool=true  # 是否无敌
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float # 重力数值
var x_max_speed: float = 9999.0  # x轴最大速度
var y_max_speed: float = 9999.0  # y轴最大速度
var current_velocity: Vector2 = Vector2.ZERO  # 当前速度
var current_drag: Vector2 = Vector2.ZERO  # 当前阻力/加速度


func _ready() -> void:
	set_physics_process(false)
	print("2.Character_Ctrler初始化完成")
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
	var move_dir = InputManager.get_vector("move_left", "move_right", "move_up", "move_down")
	move_dir.x*=character_data.direction
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
	#set_penetrate(true)

## 停止冲刺函数
func stop_dash():
	stop_move()
	set_invincible(false)
	#set_penetrate(false)

## 是否启动重力
func apply_gravity(value:bool):
	is_gravity=value

## 设置朝向
func set_direction(value:int):
	character_data.direction=value

## 设置是否可以损失hp(有受击面，可以触发受击效果)
func set_is_allow_losehp(value:bool):
	is_allow_losehp=value

## 获取可以损失hp
func get_is_allow_losehp():
	return  is_allow_losehp

## 设置是否可以被打(有受击面，但无法触发受击效果)
func set_is_allow_behit(value:bool):
	is_allow_behit=value

## 获取是否可以被打
func get_is_allow_behit():
	return is_allow_behit

## 获取碰撞体
func _get_collisionshape():
	for child in owner.get_children():
		if child is CollisionShape2D:
			return child

## 获取hurtbox
func _get_hurtbox():
	for child in owner.get_children():
		if child is Hurtbox:
			return child

## 获取hurtbox中所有的图形
func _get_hurtbox_collisionshapes() -> Array[CollisionShape2D]:
	var hurtbox: Hurtbox=_get_hurtbox()
	var shapes: Array[CollisionShape2D] = []
	for child in hurtbox.get_children():
		if child is CollisionShape2D:
			shapes.append(child)
	return shapes

## 设置是否无敌(无受击面)
func set_invincible(value:bool):
	is_invincible=value
	for shape in _get_hurtbox_collisionshapes():
		shape.set_deferred("disabled", value)

## 获取是否无敌
func get_invincible():
	return is_invincible

## 设置是否可穿越地图
func set_penetrate(value:bool):
	is_penetrate=value
	_get_collisionshape().set_deferred("disabled", value)

## 获取是否可穿越地图
func get_penetrate():
	return is_penetrate

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
	#位置偏移
	var origin = generate_position if generate_position.length() != 0 else character.global_position
	bullet_instance.global_position.x = origin.x + offset.x * character_data.direction
	bullet_instance.global_position.y = origin.y + offset.y
	#飞行物根据朝向镜像
	#bullet_instance.bullet_ctrler.initialize_mirror(character_data.direction)
	if character_data.direction == 1:
		bullet_instance.rotation += deg_to_rad(offset_rotation)
	else:
		bullet_instance.rotation += PI - deg_to_rad(offset_rotation)
	#print("飞行物自身角度：",rad_to_deg(bullet_instance.rotation))


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
	prop_instance.global_position.x = character.global_position.x + offset.x * character_data.direction
	prop_instance.global_position.y = character.global_position.y + offset.y
	prop_instance.rotation = character.rotation

## 添加警示线
func add_warning_line(generate_position:Vector2,offset:Vector2,offset_rotation:float=0.0,
	length: float = 999,width: float = 1,color: Color = Color(1.0, 1.0, 1.0, 1.0),
	grow_time: float = 0.5,keep_time: float = 0.5,shrink_time: float = 0.3):
	if not warning_line:
		return
	var line_instance = warning_line.instantiate()
	var origin = generate_position if generate_position.length() != 0 else character.global_position
	line_instance.global_position.x = origin.x + offset.x * character_data.direction
	line_instance.global_position.y = origin.y + offset.y
	var base_rot = 0.0 if character_data.direction > 0 else PI
	var final_offset_rot = deg_to_rad(offset_rotation) * character_data.direction
	line_instance.rotation = base_rot + final_offset_rot
	line_instance.set_color(color)
	line_instance.set_width(width)
	get_parent().add_child(line_instance)
	line_instance.line_animate(length,grow_time,keep_time,shrink_time)

## 添加特效
func add_effect(effect,generate_position:Vector2=character.global_position,offset:Vector2=Vector2(0,0)):
	if not effect:
		return
	var effect_instance = effect.instantiate()
	var origin = generate_position if generate_position else Vector2(0,0)
	effect_instance.global_position.x = origin.x + offset.x * character_data.direction
	effect_instance.global_position.y = origin.y + offset.y
	effect_instance.scale.x *= character_data.direction
	get_parent().add_child(effect_instance)

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
func get_target():
	var team=character_data.team
	var characters = get_tree().get_nodes_in_group("characters")
	for _character in characters:
		if _character is CharacterBody2D and not _character.is_in_group(team):
			return _character
	return null

## 瞬间移动到对方位置
func move_to_target(offect:Vector2=Vector2(0,0)):
	offect.x*=character_data.direction
	character.global_position=get_target().global_position+offect

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
