class_name EffectultimateDamageUp
extends CardEffect

@export var damage_add_percent: float = 0.5
@export var damage_add_value: float = 0.0

func apply_passive(player: CharacterBody2D) -> void:
	if not player or not player.character_data or not player.character_data.current_skill:
		return
	var hits=player.character_data.current_ultimate.hits
	for i in range(hits.size()):
		hits[i].damage_multiplier *= (1.0 + damage_add_percent)
		hits[i].damage_multiplier +=  damage_add_value
		print("卡牌被动：", player.character_data.character_name, " 的必杀",i+1,"段倍率提升至 ", hits[i].damage_multiplier*100,"%")

func remove_passive(player: CharacterBody2D) -> void:
	if not player or not player.character_data or not player.character_data.current_skill:
		return
	var hits=player.character_data.current_ultimate.hits
	for i in range(hits.size()):
		hits[i].damage_multiplier -=  damage_add_value
		hits[i].damage_multiplier /= (1.0 + damage_add_percent)
		print("卡牌卸载：", player.character_data.character_name, " 的必杀第",i+1,"段倍率恢复至 ", hits[i].damage_multiplier*100,"%")
