class_name EffectMpUp
extends CardEffect

@export var mp_add_percent: float = 0.5
@export var mp_add_value: float = 0.0

func apply_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.mp_max *= (1.0 + mp_add_percent)
		player.character_data.mp *= (1.0 + mp_add_percent)
		player.character_data.mp_max += mp_add_value
		player.character_data.mp += mp_add_value
		print("卡牌被动：", player.character_data.character_name, " 的魔力提升至 ", player.character_data.mp_max)

func remove_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.mp_max -= mp_add_value
		player.character_data.mp -= mp_add_value
		player.character_data.mp_max /= (1.0 + mp_add_percent)
		player.character_data.mp /= (1.0 + mp_add_percent)
		print("卡牌卸载：", player.character_data.character_name, " 的魔力恢复至 ", player.character_data.mp_max)
