extends CharacterBody2D
#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@export var attack_bullet:PackedScene
@export var skill1_bullet:PackedScene
@export var ultimate1_bullet:PackedScene


var character_name:String="东风谷早苗"

func _ready():
	print("3.character初始化完成:",character_name)

func _physics_process(_delta: float) -> void:
	pass

func normal_attack():
	character_ctrler.shoot(attack_bullet,Vector2(50,0))

func skill1():
	var skill_hits=character_data.current_skill.hits
	var x=randf_range(-50, 50)
	var y=randf_range(-50, -100)
	character_ctrler.shoot(skill1_bullet,Vector2(x,y),0,Vector2(0,0),skill_hits)
	pass

func ultimate1():
	var skill_hits=character_data.current_ultimate.hits
	for i in range(0,5):
		character_ctrler.shoot(ultimate1_bullet,Vector2(50,i*10),i*1,Vector2(0,0),skill_hits)
		character_ctrler.shoot(ultimate1_bullet,Vector2(50,-i*10),-i*1,Vector2(0,0),skill_hits)
		await get_tree().create_timer(0.1, false).timeout
