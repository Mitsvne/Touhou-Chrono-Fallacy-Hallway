class_name EffectHpUp
extends CardEffect

@export var hp_add_percent: float = 0.5
@export var hp_add_value: float = 0.0

func apply_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.hp_max *= (1.0 + hp_add_percent)
		player.character_data.hp *= (1.0 + hp_add_percent)
		player.character_data.hp_max += hp_add_value
		player.character_data.hp += hp_add_value
		print("卡牌被动：", player.character_data.character_name, " 的血量提升至 ", player.character_data.hp_max)

func remove_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.hp_max -= hp_add_value
		player.character_data.hp -= hp_add_value
		player.character_data.hp_max /= (1.0 + hp_add_percent)
		player.character_data.hp /= (1.0 + hp_add_percent)
		print("卡牌卸载：", player.character_data.character_name, " 的血量恢复至 ", player.character_data.hp_max)
