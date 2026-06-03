class_name EffectEnergyUp
extends CardEffect

@export var energy_add_percent: float = 0.5
@export var energy_add_value: float = 0.0
@export var energy_regen_add_percent: float = 0.0
@export var energy_regen_add_value: float = 0.0

func apply_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.energy_max += player.character_data.energy_max * energy_add_percent
		player.character_data.energy += player.character_data.energy * energy_add_percent
		player.character_data.energy_max += energy_add_value
		player.character_data.energy += energy_add_value
		print("卡牌被动：", player.character_data.character_name, " 的耐力提升至 ", player.character_data.energy_max)
		player.character_data.energy_regen += player.character_data.energy_regen * energy_regen_add_percent
		player.character_data.energy_regen += energy_regen_add_value
		print("卡牌被动：", player.character_data.character_name, " 的耐力恢复速度提升至 ", player.character_data.energy_regen)

func remove_passive(player: CharacterBody2D) -> void:
	if player.character_data:
		player.character_data.energy_max -= energy_add_value
		player.character_data.energy -= energy_add_value
		player.character_data.energy_max -= player.character_data.energy_max * energy_add_percent
		player.character_data.energy -= player.character_data.enerenergy_regengy * energy_add_percent
		player.character_data.energy_regen -= energy_regen_add_value
		player.character_data.energy_regen -= player.character_data.energy_regen * energy_regen_add_percent
