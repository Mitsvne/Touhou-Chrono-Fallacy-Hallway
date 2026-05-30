class_name EffectSpeedUp
extends CardEffect

@export var speed_add_value: float = 50.0

func apply_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.move_speed += speed_add_value
		print("卡牌被动：", player.character_data.character_name, " 的速度提升至 ", player.character_data.move_speed)

func remove_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.move_speed -= speed_add_value
