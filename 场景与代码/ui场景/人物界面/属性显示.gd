extends Control

@export var hp_label: Label
@export var mp_label: Label
@export var energy_label: Label
@export var power_label: Label
@export var speed_label: Label


func _ready() -> void:
	GameData.character_changed.connect(_update_attributes)


func _update_attributes(char_data: CharacterData)-> void:
	hp_label.text="血量："+str(int(char_data.base_hp))
	mp_label.text="魔力："+str(int(char_data.base_mp))
	energy_label.text="耐力："+str(int(char_data.base_energy))
	power_label.text="攻击："+str(int(char_data.base_power))
	speed_label.text="移速："+str(int(char_data.base_speed))
