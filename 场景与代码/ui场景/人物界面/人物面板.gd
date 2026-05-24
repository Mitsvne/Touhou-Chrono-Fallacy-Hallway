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

var animation_list: PackedStringArray  = []   # 所有动画的名称列表
var current_index: int = 0


func _ready() -> void:
	if an.sprite_frames:
		animation_list = an.sprite_frames.get_animation_names()
	btn_left.pressed.connect(_on_left_pressed)
	btn_right.pressed.connect(_on_right_pressed)
	btn_appearance.pressed.connect(_on_appearance_pressed)
	if not animation_list.is_empty():
		play_animation_at_index(0)
	update_content()


func _process(_delta: float) -> void:
	pass

## 更新显示内容
func update_content():
	if GameData.get_current_character():
		btn_appearance.text="登场角色："+GameData.get_current_character()
	var char_id:String=animation_list[current_index]
	name_label.text=char_id
	hp_label.text="血量："+str(GameData.get_stat(char_id,"hp"))
	mp_label.text="魔力："+str(GameData.get_stat(char_id,"mp"))
	energy_label.text="耐力："+str(GameData.get_stat(char_id,"energy"))
	power_label.text="攻击："+str(GameData.get_stat(char_id,"power"))
	speed_label.text="移速："+str(GameData.get_stat(char_id,"speed"))

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
	GameData.set_current_character(animation_list[current_index])
	btn_appearance.text="登场角色："+GameData.get_current_character()
