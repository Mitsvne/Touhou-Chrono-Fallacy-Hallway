extends Node
class_name Bullet_Data


var bullet_team: String
var bullet_owner: CharacterBody2D

@export var bullet_name: String
@export var bullet_hp_max:float=10
@onready var bullet_hp:float=bullet_hp_max:
	set(v):
		v=clampf(v,0.0,bullet_hp_max)
		if bullet_hp==v:
			return
		bullet_hp=v

@onready var bullet_direction:float=1.0:
	set(v):
		if (v==1.0 or v==-1.0) and bullet_direction!=v:
			bullet_direction=v
		else:
			return

func get_bullet_team():
	return bullet_team

func set_bullet_team(value:String):
	bullet_team=value

func get_bullet_owner():
	return bullet_owner

func set_bullet_owner(value:CharacterBody2D):
	bullet_owner=value
	
func get_bullet_hp():
	return bullet_hp

func set_bullet_hp(value:float):
	bullet_hp=value
	
func get_bullet_hp_max():
	return bullet_hp

func set_bullet_hp_max(value:float):
	bullet_hp=value

func get_bullet_direction():
	return bullet_direction

func set_bullet_direction(value:float):
	bullet_direction=value
