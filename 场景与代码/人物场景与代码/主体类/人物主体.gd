extends Node
class_name Character_mian
signal hp_changed
signal energy_changed
#血量上限
@export var hp_max:float=100
#血量
@onready var hp:float=hp_max:
	set(v):
		v=clampf(v,0.0,hp_max)
		if hp==v:
			return
		hp=v
		hp_changed.emit()
#耐力上限
@export var energy_max:float=100
#耐力恢复速度
@export var energy_regen:float=10
#耐力
@onready var energy:float=energy_max:
	set(v):
		v=clampf(v,0.0,energy_max)
		if energy==v:
			return
		energy=v
		energy_changed.emit()
@export var team:String="1P"

func _process(delta: float) -> void:
	#时刻恢复耐力
	energy+=energy_regen*delta
