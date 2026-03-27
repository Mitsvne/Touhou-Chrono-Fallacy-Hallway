extends Node
class_name Character_Ctrler
@export var character:CharacterBody2D
@export var character_mian:Character_mian



func shoot(Bullet,offset:Vector2):
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
