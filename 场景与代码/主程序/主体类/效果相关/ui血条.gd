extends HBoxContainer
@export var character:CharacterBody2D
@export var character_data:Character_Data

@export var hp_bar: TextureProgressBar
@export var delay_hp_bar: TextureProgressBar
@export var mp_bar: TextureProgressBar
@export var delay_mp_bar: TextureProgressBar
@export var energy_bar: TextureProgressBar
@export var delay_energy_bar: TextureProgressBar
@export var avatars: PanelContainer

func _ready() -> void:
	await get_tree().process_frame
	if not character_data:
		printerr("character_data 未在检查器中赋值！")
		return
	if not character:
		printerr("Character 未在检查器中赋值！")
		return
	#连接信号
	character_data.hp_changed.connect(update_hp)
	character_data.mp_changed.connect(update_mp)
	character_data.energy_changed.connect(update_energy)
	#初始执行一次
	update_hp(character_data.hp,character_data.hp_max)
	update_mp(character_data.mp,character_data.hp_max)
	update_energy(character_data.energy,character_data.energy_max)
	
	update_avatar()
	#print("血条ui初始化完成 血量：%s 耐力：%s 魔力：%s"%[character_data.hp,character_data.energy,character_data.mp])

func update_hp(hp:float,hp_max:float):
	var percentage:=character_data.hp/float(character_data.hp_max)
	hp_bar.value=percentage
	create_tween().tween_property(delay_hp_bar,"value",percentage,0.3)

func update_mp(mp:float,mp_max:float):
	var percentage:=character_data.mp/float(character_data.mp_max)
	mp_bar.value=percentage
	create_tween().tween_property(delay_mp_bar,"value",percentage,0.5)

func update_energy(energy:float,energy_max:float):
	var percentage:=character_data.energy/character_data.energy_max
	energy_bar.value=percentage
	create_tween().tween_property(delay_energy_bar,"value",percentage,0.3)





func update_avatar():
	for child in avatars.get_children():
		if child is TextureRect and child.name==character.character_name:
			child.modulate.a = 1.0
		else:
			child.modulate.a = 0.0
