extends CharacterBody2D
#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@export var skill_component: SkillComponent

@export var attack_bullet:PackedScene
@export var bullet2:PackedScene
@export var bullet3:PackedScene
@export var skill2_bullet:PackedScene

var character_name:String="博丽灵梦"
var active_effects: Array[CardEffect] = []

func _ready():
	if character_data:
		_initialize_card_effects()
	print("3.character初始化完成:",character_name)
	
	
func _physics_process(_delta: float) -> void:
	pass

## 1. 注入并激活属于该角色的所有卡牌
func _initialize_card_effects() -> void:
	if GameData == null or GameData.current_character_data == null:
		return
	var char_data = GameData.current_character_data
	# 遍历人物身上的所有装备卡
	for card in char_data.equipped_cards:
		if card == null: continue
		for effect in card.effects:
			if effect == null: continue
			var runtime_effect = effect.duplicate() as CardEffect
			active_effects.append(runtime_effect)
			# 立即触发被动钩子
			runtime_effect.apply_passive(self)

func skill2(start_angle:int=30):
	for i in range(6):
		var current_angle_deg = start_angle + i * 5
		var current_angle_rad = deg_to_rad(current_angle_deg)
		var x = 100 * cos(current_angle_rad)
		var y = 100 * sin(current_angle_rad)
		character_ctrler.shoot(skill2_bullet,Vector2(x,y),current_angle_deg)
