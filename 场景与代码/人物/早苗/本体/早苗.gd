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

func _ready():
	print("3.character初始化完成:",character_name)

func _physics_process(_delta: float) -> void:
	pass

func normal_attack():
	character_ctrler.shoot(attack_bullet,Vector2(50,0))
