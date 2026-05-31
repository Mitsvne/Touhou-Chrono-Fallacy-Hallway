class_name CharacterSelector
extends Control

@export var left_button: TextureButton
@export var right_button: TextureButton
@export var name_label: Label
@export var an: AnimatedSprite2D
@export var deploy: Button

var character_resources: Array[CharacterData] = []
var current_index: int = 0

func _ready() -> void:
	character_resources=GameData.unlocked_characters
	# 1. 绑定左右箭头的点击事件
	left_button.pressed.connect(_on_left_arrow_pressed)
	right_button.pressed.connect(_on_right_arrow_pressed)
	deploy.pressed.connect(_on_deploy_pressed)
	# 2. 默认激活第一个角色 (Index = 0)
	_update_selection()

## ==================== 核心逻辑：循环切换 ====================

## 点击左箭头：上一个角色
func _on_left_arrow_pressed() -> void:
	current_index -= 1
	if current_index < 0:
		current_index = character_resources.size() - 1
	_update_selection()

## 点击右箭头：下一个角色
func _on_right_arrow_pressed() -> void:
	current_index += 1
	if current_index >= character_resources.size():
		current_index = 0
	_update_selection()

## 登场按钮：切换当前角色为登场角色
func _on_deploy_pressed() -> void:
	GameData.current_deploy_character_data=GameData.current_character_data
	deploy.text="当前登场："+GameData.current_deploy_character_data.character_name

## ==================== 数据同步中心 ====================

func _update_selection() -> void:
	var target_char_data = character_resources[current_index]
	if name_label:
		name_label.text = target_char_data.character_name
	if an:
		an.play(target_char_data.character_name)
	GameData.current_character_data = target_char_data
