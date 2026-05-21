class_name MaxHPEffect
extends AccessoryEffect

@export var hp_bonus: int = 20

func on_equip(target: Node) -> void:
	if "max_hp" in target:
		target.max_hp += hp_bonus

func on_unequip(target: Node) -> void:
	if "max_hp" in target:
		target.max_hp -= hp_bonus
