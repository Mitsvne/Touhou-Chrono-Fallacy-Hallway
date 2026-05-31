extends Control

@export var reg_slot_1: SkillSlotUI
@export var reg_slot_2: SkillSlotUI
@export var ult_slot_1: SkillSlotUI
@export var ult_slot_2: SkillSlotUI

func _ready() -> void:
	var all_slots = [reg_slot_1, reg_slot_2, ult_slot_1, ult_slot_2]
	for slot in all_slots:
		slot.slot_clicked.connect(_on_slot_clicked)
	GameData.character_changed.connect(_on_character_changed)
	_refresh_all_slots()

func _on_character_changed(new_character: CharacterData) -> void:
	# 检查这个新英雄是不是第一次出战。如果是，默认帮他勾选第一个技能和必杀
	_ensure_default_equipment(new_character)
	# 重新刷新一整页的 4 个格子
	_refresh_all_slots()

## 刷新ui
func _refresh_all_slots() -> void:
	var character = GameData.current_character_data
	if character == null: return
	_ensure_default_equipment(character)
	reg_slot_1.update_slot(character.available_skills[0] if character.available_skills.size() > 0 else null, character.equipped_skill)
	reg_slot_2.update_slot(character.available_skills[1] if character.available_skills.size() > 1 else null, character.equipped_skill)
	ult_slot_1.update_slot(character.available_ultimates[0] if character.available_ultimates.size() > 0 else null, character.equipped_ultimate)
	ult_slot_2.update_slot(character.available_ultimates[1] if character.available_ultimates.size() > 1 else null, character.equipped_ultimate)

## 当点击槽位时
func _on_slot_clicked(slot: SkillSlotUI) -> void:
	var character = GameData.current_character_data
	var data = slot.skill_data
	if data.skill_type == SkillData.SkillType.REGULAR:
		character.equipped_skill = data
	else:
		character.equipped_ultimate = data
	_refresh_all_slots()

## 防止出现忘记在资源里预先勾选默认装备，导致格子全暗”的尴尬情况
func _ensure_default_equipment(character: CharacterData) -> void:
	if character == null: return
	# 如果没有装备普通技能，默认穿上技能池的第一个
	if character.equipped_skill == null and character.available_skills.size() > 0:
		character.equipped_skill = character.available_skills[0]
	# 如果没有装备必杀技，默认穿上必杀池的第一个
	if character.equipped_ultimate == null and character.available_ultimates.size() > 0:
		character.equipped_ultimate = character.available_ultimates[0]
