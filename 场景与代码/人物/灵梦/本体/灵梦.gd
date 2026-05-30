extends CharacterBody2D
#控制器导入
@export var characterdata: CharacterData
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler

var character_name:String="博丽灵梦"
var active_effects: Array[CardEffect] = []

@export var audio: AudioStreamPlayer
@export var attack_bullet:PackedScene
@export var bullet2:PackedScene
@export var bullet3:PackedScene

func _ready():
	if character_data:
		_initialize_card_effects()
	print("3.character初始化完成:",character_name)
	
	
func _physics_process(_delta: float) -> void:
	pass


func play_audio():
	audio.play()
	
## 1. 注入并激活属于该角色的所有卡牌
func _initialize_card_effects() -> void:
	# 安全检查：是否能拿到全局选择的角色数据
	if GameData == null or GameData.current_character_data == null:
		return
	var char_data = GameData.current_character_data
	# 遍历人物身上的所有装备卡
	for card in char_data.equipped_cards:
		if card == null: continue
		# 遍历一张卡牌包含的多个效果
		for effect in card.effects:
			if effect == null: continue
			# 【核心避坑】必须使用 .duplicate() 实例化资源！
			# 否则如果有多只怪物或多个玩家装备同一张卡，它们会共享同一个内存里的数值
			var runtime_effect = effect.duplicate() as CardEffect
			# 存入实例池
			active_effects.append(runtime_effect)
			# 立即触发被动钩子
			runtime_effect.apply_passive(self)
