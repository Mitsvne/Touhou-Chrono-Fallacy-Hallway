extends Node
class_name Prop_Data

var team: String
var prop_owner: CharacterBody2D

@export var prop_name: String
@onready var direction:float=1.0:
	set(v):
		if (v==1.0 or v==-1.0) and direction!=v:
			direction=v
		else:
			return

@export var hp_max:float=10#血量上限
@onready var hp:float=hp_max:#血量
	set(v):
		v=clampf(v,0.0,hp_max)
		if hp==v:
			return
		hp=v
		#bullet_hp_changed.emit(bullet_hp,bullet_hp_max)

func _ready() -> void:
	pass # Replace with function body.
