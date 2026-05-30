class_name CharacterSelector
extends Control

# 在 Inspector 中拖入所有角色的 .tres 资源文件
@export var character_resources: Array[CharacterData] = []

# 自动获取内部按钮和文本节点的引用
@export var left_button: TextureButton
@export var right_button: TextureButton
@export var name_label: Label
@export var an: AnimatedSprite2D
@export var deploy: Button

# 核心指针：记录当前正在看第几个角色
var current_index: int = 0

func _ready() -> void:
	if character_resources.is_empty():
		push_error("CharacterSelector: 角色资源列表为空，请在 Inspector 中添加 CharacterData 资源！")
		return
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
