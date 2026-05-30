# CardManager.gd (全局单例)
extends Node

# 数据结构：{ "character_id_1": [Card1, Card2, null], "character_id_2": [...] }
var all_character_equipments: Dictionary = {}

const MAX_SLOTS = 2

# 装备卡牌时，需要传入是哪一个角色值
func equip_card_for(character_id: String, card: ItemCardData, slot_index: int) -> void:
	if not all_character_equipments.has(character_id):
		var new_slots: Array[ItemCardData] = []
		new_slots.resize(MAX_SLOTS)
		all_character_equipments[character_id] = new_slots
		
	all_character_equipments[character_id][slot_index] = card

# 获取指定角色的卡牌列表
func get_equipped_cards_for(character_id: String) -> Array:
	if all_character_equipments.has(character_id):
		return all_character_equipments[character_id]
	return []
