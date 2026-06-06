extends CharacterBody2D
#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@export var attack_bullet:PackedScene
@export var skill1_bullet:PackedScene
@export var skill2_bullet:PackedScene

var character_name:String="东风谷早苗"
var active_effects: Array[CardEffect] = []

func _ready():
	if character_data:
		_initialize_card_effects()
	print("3.character初始化完成:",character_name)

func _physics_process(_delta: float) -> void:
	pass

func _initialize_card_effects() -> void:
	if GameData == null or GameData.current_character_data == null:
		return
	var char_data = GameData.current_character_data
	for card in char_data.equipped_cards:
		if card == null: continue
		for effect in card.effects:
			if effect == null: continue
			var runtime_effect = effect.duplicate() as CardEffect
			active_effects.append(runtime_effect)
			runtime_effect.apply_passive(self)
