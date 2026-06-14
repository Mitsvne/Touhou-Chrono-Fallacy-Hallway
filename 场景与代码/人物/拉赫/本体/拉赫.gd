extends CharacterBody2D

# 控制器
@export var character_ai_main: Character_AI_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@export var bt_player: BTPlayer
@export var skill_host: SkillHost

@export var book: PackedScene
@onready var halo: Node2D = $VisualNode/光环

var character_name: String = "拉赫莱蒂"


func _ready() -> void:
	character_ctrler.add_prop(book, Vector2(0, -50))
	skill_host.setup(self, character_data, character_ctrler, effect_ctrler, character_ai_main.anplayer)
	print("3.character初始化完成:", character_name)
