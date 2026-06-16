class_name CharacterData
extends Resource

@export_file("*.tscn") var character_scene_path: String
@export var character_id: String = ""
@export var character_name: String = ""
@export var avatar: Texture2D

@export_group("基础属性", "")
@export var base_hp: float = 200.0
@export var base_mp: float = 100.0
@export var base_speed: float = 400.0
@export var base_acceleration: float = 1600.0
@export var base_friction: float = 1200.0
@export var base_power: float = 10.0
@export var base_energy: float = 100.0
@export var base_energy_regen: float = 10.0
@export var base_attack_interval:float=0.3

@export_group("技能配置池", "")
@export var available_skills: Array[SkillData] = []     # 存放 2 个普通技能资源
@export var available_ultimates: Array[SkillData] = []  # 存放 2 个必杀技资源

@export_group("当前装备的技能", "")
@export var equipped_skill: SkillData
@export var equipped_ultimate: SkillData

@export_group("道具卡", "")
@export var equipped_cards: Array[ItemCardData] = []

# 每个角色独享自己的道具卡插槽
const MAX_SLOTS = 2

# 初始化插槽数量
func _init() -> void:
	if equipped_cards.is_empty():
		equipped_cards.resize(MAX_SLOTS)
