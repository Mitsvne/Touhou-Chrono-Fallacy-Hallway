extends Control

@export var an: AnimatedSprite2D
@export var btn_appearance: Button
@export var name_label: Label
@export var hp_label: Label
@export var mp_label: Label
@export var energy_label: Label
@export var power_label: Label
@export var speed_label: Label
@export var btn_left: TextureButton
@export var btn_right: TextureButton

@export var skill_label: Label
@export var ultimate_label: Label
@export var skill_box: HBoxContainer
@export var ultimate_box: HBoxContainer
@export var btn_skill1: Button
@export var btn_skill2: Button
@export var btn_ultimate1: Button
@export var btn_ultimate2: Button

@export var item_card_box: HBoxContainer
@export var item_card_label: Label

var animation_list: PackedStringArray  = []   # 所有动画的名称列表
var current_index: int = 1
var current_char_name: String

func _ready() -> void:
	if an.sprite_frames:
		animation_list = an.sprite_frames.get_animation_names()
	btn_left.pressed.connect(_on_left_pressed)
	btn_right.pressed.connect(_on_right_pressed)
	btn_appearance.pressed.connect(_on_appearance_pressed)
	for skill in skill_box.get_children():
		if skill is Button:
			skill.pressed.connect(_on_skill_pressed.bind(skill.name))
	for ultimate in ultimate_box.get_children():
		if ultimate is Button:
			ultimate.pressed.connect(_on_ultimate_pressed.bind(ultimate.name))
	#btn_skill1.pressed.connect(_on_skill1_pressed)
	#btn_skill2.pressed.connect(_on_skill2_pressed)
	#btn_ultimate1.pressed.connect(_on_ultimate1_pressed)
	#btn_ultimate2.pressed.connect(_on_ultimate2_pressed)
	for card in item_card_box.get_children():
		if card is Button:
			card.pressed.connect(_on_card_pressed.bind(card.name))
	if not animation_list.is_empty():
		play_animation_at_index(current_index)
	update_content()


func _process(_delta: float) -> void:
	pass

## 更新显示内容
func update_content():
	if GameData.get_current_character():
		btn_appearance.text="登场角色："+GameData.get_current_character()
	var char_name:String=animation_list[current_index]
	current_char_name=char_name
	name_label.text=char_name
	hp_label.text="血量："+str(GameData.get_stat(char_name,"hp"))
	mp_label.text="魔力："+str(GameData.get_stat(char_name,"mp"))
	energy_label.text="耐力："+str(GameData.get_stat(char_name,"energy"))
	power_label.text="攻击："+str(GameData.get_stat(char_name,"power"))
	speed_label.text="移速："+str(GameData.get_stat(char_name,"speed"))
	btn_skill1.icon=GameData.get_stat(char_name,"skill1_icon")
	btn_skill2.icon=GameData.get_stat(char_name,"skill2_icon")
	btn_ultimate1.icon=GameData.get_stat(char_name,"ultimate1_icon")
	btn_ultimate2.icon=GameData.get_stat(char_name,"ultimate2_icon")
	skill_label.text="当前："+GameData.get_stat(char_name,"skill")
	ultimate_label.text="当前："+GameData.get_stat(char_name,"ultimate")
	item_card_label.text="道具卡："+GameData.get_stat(char_name,"item_card")

## 播放对应索引的动画
func play_animation_at_index(index: int) -> void:
	if index >= 0 and index < animation_list.size():
		var anim_name = animation_list[index]
		an.animation = anim_name
		an.play()

## 左按钮，上一个角色
func _on_left_pressed() -> void:
	if animation_list.is_empty():
		return
	current_index = wrapi(current_index - 1, 0, animation_list.size())
	play_animation_at_index(current_index)
	update_content()

## 右按钮，下一个角色
func _on_right_pressed() -> void:
	if animation_list.is_empty():
		return
	current_index = wrapi(current_index + 1, 0, animation_list.size())
	play_animation_at_index(current_index)
	update_content()

## 登场按钮，使当前角色登场
func _on_appearance_pressed() -> void:
	var character_name:String=animation_list[current_index]
	GameData.set_current_character(character_name)
	EventBus.character_changed.emit(character_name)
	btn_appearance.text="登场角色："+GameData.get_current_character()
	
func _on_skill_pressed(id: String) -> void:
	GameData.set_character_stat(current_char_name,"skill",id)
	update_content()
	
func _on_ultimate_pressed(id: String) -> void:
	GameData.set_character_stat(current_char_name,"ultimate",id)
	update_content()

func _on_card_pressed(id: String) -> void:
	GameData.set_character_stat(current_char_name,"item_card",id)
	update_content()
