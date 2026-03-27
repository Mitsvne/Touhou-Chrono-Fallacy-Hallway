class_name Stats
extends Node
signal hp_changed
@export var hp_max:int=100
@onready var hp:int=hp_max:
	set(v):
		v=clampi(v,0,hp_max)
		if hp==v:
			return
		hp=v
		hp_changed.emit()


signal energy_changed
@export var energy_max:float=100
@export var energy_regen:float=10
@onready var energy:float=energy_max:
	set(v):
		v=clampf(v,0,energy_max)
		if energy==v:
			return
		energy=v
		energy_changed.emit()
		
func _process(delta: float) -> void:
	energy+=energy_regen*delta
