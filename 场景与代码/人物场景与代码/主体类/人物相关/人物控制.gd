extends Node
class_name Character_Ctrler
@export var character:CharacterBody2D

var is_gravity:bool=false
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float

func _ready() -> void:
	print("Character_Ctrler初始化完成")




##私有：根据阻力和加速度更新速度
static func _update_velocity(velocity: Vector2, drag_x: float, drag_y: float, delta: float) -> Vector2:
	if drag_x >= 0:
		var factor = max(0.0, 1 - drag_x * delta)
		velocity.x *= factor
	else:
		velocity.x += -drag_x * delta
	if drag_y >= 0:
		var factor = max(0.0, 1 - drag_y * delta)
		velocity.y *= factor
	else:
		velocity.y += -drag_y * delta
	return velocity


##移动函数
func move(velocity: Vector2=Vector2(0,0),drag_x: float=0.0,drag_y: float=0.0):
	while true:
		# 检查节点是否仍然有效（避免场景重置后继续运行）
		if not is_instance_valid(self) or not is_instance_valid(character):
			break
		var delta = get_process_delta_time()
		if is_gravity:
			velocity.y += gravity * delta
		velocity = _update_velocity(velocity, drag_x, drag_y, delta)
		character.position += velocity * delta
		# 检查树是否有效，避免 get_tree() 返回 null
		var tree = get_tree()
		if not tree:
			break
		await tree.process_frame


##停止移动函数
func stop_move():
	character.velocity=Vector2.ZERO


##是否启动重力
func apply_gravity(value:bool):
	is_gravity=value
	


	
	


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
