class_name CharacterData
extends Resource

@export_file("*.tscn") var character_scene_path: String
@export var character_id: String = ""
@export var character_name: String = ""
@export var base_hp: float = 200.0
@export var base_mp: float = 100.0
@export var base_speed: float = 400.0
@export var base_acceleration: float = 1600.0
@export var base_friction: float = 1200.0
@export var base_power: float = 10.0
@export var base_energy: float = 100.0
@export var base_energy_regen: float = 10.0
@export var base_attack_interval:float=0.3
@export var base_skill_cd:float=3.0

# 每个角色独享自己的道具卡插槽
const MAX_SLOTS = 2
@export var equipped_cards: Array[ItemCardData] = []

# 初始化插槽数量
func _init() -> void:
	if equipped_cards.is_empty():
		equipped_cards.resize(MAX_SLOTS)
