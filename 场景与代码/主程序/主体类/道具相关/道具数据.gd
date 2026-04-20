extends Node
class_name Prop_Data

var prop_team: String
var prop_owner: CharacterBody2D

@export var prop_name: String
@onready var prop_direction:float=1.0:
	set(v):
		if (v==1.0 or v==-1.0) and prop_direction!=v:
			prop_direction=v
		else:
			return

@export var prop_hp_max:float=10#血量上限
@onready var prop_hp:float=prop_hp_max:#血量
	set(v):
		v=clampf(v,0.0,prop_hp_max)
		if prop_hp==v:
			return
		prop_hp=v
		#bullet_hp_changed.emit(bullet_hp,bullet_hp_max)

func _ready() -> void:
	pass # Replace with function body.
