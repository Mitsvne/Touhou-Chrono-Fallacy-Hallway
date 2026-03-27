extends HBoxContainer
@export var character:CharacterBody2D
@export var character_data:Character_Data
@onready var hp_bar: TextureProgressBar = $血条耐力条/血条/血条
@onready var red_hp_bar: TextureProgressBar = $血条耐力条/血条/延迟红血
@onready var energy_bar: TextureProgressBar = $血条耐力条/耐力条/耐力条
@onready var avatars: PanelContainer = $头像框

func _ready() -> void:
	if not character_data:
		printerr("character_data 未在检查器中赋值！")
		return
	if not character:
		printerr("Character 未在检查器中赋值！")
		return
	#连接信号
	character_data.hp_changed.connect(update_hp)
	character_data.energy_changed.connect(update_energy)
	#初始执行一次
	update_hp()
	update_energy()
	update_avatar()

func update_hp():
	var percentage:=character_data.hp/float(character_data.hp_max)
	hp_bar.value=percentage
	create_tween().tween_property(red_hp_bar,"value",percentage,0.3)

func update_energy():
	var percentage:=character_data.energy/character_data.energy_max
	energy_bar.value=percentage

func update_avatar():
	for child in avatars.get_children():
		if child is TextureRect and child.name==character.character_name:
			child.modulate.a = 1.0
		else:
			child.modulate.a = 0.0
