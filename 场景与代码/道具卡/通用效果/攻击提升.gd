class_name EffectPowerUp
extends CardEffect

@export var power_add_percent: float = 0.5
@export var power_add_value: float = 0.0

func apply_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.power += player.character_data. power * power_add_percent
		player.character_data.power +=  power_add_value
		print("卡牌被动：", player.character_data.character_name, " 的攻击力提升至 ", player.character_data.power)

func remove_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.power -=  power_add_value
		player.character_data.power -= player.character_data.power * power_add_percent
