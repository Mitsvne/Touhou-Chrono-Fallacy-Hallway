extends Node
class_name Bullet_Data


var team: String
var bullet_owner: CharacterBody2D

@export var bullet_name: String
@export var hp_max:float=10
@onready var hp:float=hp_max:
	set(v):
		v=clampf(v,0.0,hp_max)
		if hp==v:
			return
		hp=v

@onready var direction:float=1.0:
	set(v):
		if (v==1.0 or v==-1.0) and direction!=v:
			direction=v
		else:
			return
