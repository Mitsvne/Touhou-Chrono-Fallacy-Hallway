extends Control

# 引入做好的卡牌 UI 预制体，用于动态生成背包里的卡牌
@export var card_ui_prefab: PackedScene = preload("res://场景与代码/ui场景/人物界面/道具卡ui.tscn")
@export var equipped_slots: HBoxContainer       #装备栏
@export var inventory_grid: HBoxContainer       #仓库栏

# 运行时状态数据
var active_char_data: CharacterData = null
var selected_inventory_card: ItemCardData = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameData.character_changed.connect(_on_character_changed)
	if GameData.current_character_data:
		_on_character_changed(GameData.current_character_data)
	_refresh_inventory()

## 当角色发生改变时，换一套数据刷新 UI
func _on_character_changed(new_char_data: CharacterData) -> void:
	active_char_data = new_char_data
	selected_inventory_card = null # 切换英雄时清空背包选择
	_refresh_equipped_slots()

## ==================== 装备槽与背包刷新逻辑 ====================

func _refresh_equipped_slots() -> void:
	if not active_char_data: return
	for slot_index in range(active_char_data.equipped_cards.size()):
		var card_data = active_char_data.equipped_cards[slot_index]
		var slot_node = equipped_slots.get_child(slot_index) as ItemCardUI
		if slot_node.card_selected.is_connected(_on_slot_clicked):
			slot_node.card_selected.disconnect(_on_slot_clicked)
		slot_node.card_selected.connect(_on_slot_clicked.bind(slot_index))
		slot_node.init_card(card_data)
	
func _refresh_inventory() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()
	for card_data in GameData.all_owned_cards:
		var card_ui = card_ui_prefab.instantiate() as ItemCardUI
		inventory_grid.add_child(card_ui)
		card_ui.custom_minimum_size=Vector2(41,65)
		card_ui.init_card(card_data)
		card_ui.card_selected.connect(_on_inventory_card_clicked)
		
## ==================== 穿脱交互逻辑 ====================

func _on_inventory_card_clicked(card_data: ItemCardData) -> void:
	selected_inventory_card = card_data
	# 自动寻找空槽位装备
	var empty_slot = active_char_data.equipped_cards.find(null)
	if empty_slot != -1:
		_equip_card(card_data, empty_slot)

func _on_slot_clicked(_card_data: ItemCardData, slot_index: int) -> void:
	# 槽位有卡则卸下
	if active_char_data.equipped_cards[slot_index] != null:
		active_char_data.equipped_cards[slot_index] = null
		_refresh_equipped_slots()
	# 槽位为空且选了背包卡则装备
	elif selected_inventory_card != null:
		_equip_card(selected_inventory_card, slot_index)

func _equip_card(card_data: ItemCardData, slot_index: int) -> void:
	if active_char_data.equipped_cards.has(card_data):
		return # 防重复装备
	active_char_data.equipped_cards[slot_index] = card_data
	selected_inventory_card = null
	_refresh_equipped_slots()
