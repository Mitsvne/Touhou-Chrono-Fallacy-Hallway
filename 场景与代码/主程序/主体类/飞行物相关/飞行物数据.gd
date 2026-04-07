extends Node
class_name Bullet_Data

#signal bullet_hp_changed
#signal bullet_direction_changed

var bullet_team: String

@onready var bullet_direction:float=1.0:
	set(v):
		if (v==1.0 or v==-1.0) and bullet_direction!=v:
			bullet_direction=v
		else:
			return

@export var bullet_hp_max:float=10#血量上限
@onready var bullet_hp:float=bullet_hp_max:#血量
	set(v):
		v=clampf(v,0.0,bullet_hp_max)
		if bullet_hp==v:
			return
		bullet_hp=v
		#bullet_hp_changed.emit(bullet_hp,bullet_hp_max)

func _ready() -> void:
	pass # Replace with function body.
