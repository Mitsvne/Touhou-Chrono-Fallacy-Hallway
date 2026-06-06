extends CharacterBody2D
#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler

@export var attack_bullet:PackedScene
@export var skill1_bullet:PackedScene
@export var skill2_bullet:PackedScene
@export var ultimate1_bullet1:PackedScene
@export var ultimate1_bullet2:PackedScene
@export var ultimate1_bullet3:PackedScene
@export var ultimate2_bullet:PackedScene

var character_name:String="博丽灵梦"

func _ready():
	print("3.character初始化完成:",character_name)
	
	
func _physics_process(_delta: float) -> void:
	pass

func skill1(offset:Vector2=Vector2(0,0)):
	var skill_hits=character_data.current_skill.hits
	character_ctrler.shoot(skill1_bullet,offset,0,Vector2(0,0),skill_hits)
	
func skill2(start_angle:int=30):
	var skill_hits=character_data.current_skill.hits
	for i in range(6):
		var current_angle_deg = start_angle + i * 5
		var current_angle_rad = deg_to_rad(current_angle_deg)
		var x = 100 * cos(current_angle_rad)
		var y = 100 * sin(current_angle_rad)
		character_ctrler.shoot(skill2_bullet,Vector2(x,y),current_angle_deg,Vector2(0,0),skill_hits)

func ultimate1(type:int=1,offset_rotation:float=0):
	var skill_hits=character_data.current_ultimate.hits
	if type==1:
		character_ctrler.shoot(ultimate1_bullet1,Vector2(0,0),offset_rotation,Vector2(0,0),skill_hits)
	elif type==2:
		character_ctrler.shoot(ultimate1_bullet2,Vector2(0,0),offset_rotation,Vector2(0,0),skill_hits)
	elif type==3:
		character_ctrler.shoot(ultimate1_bullet3,Vector2(0,0),offset_rotation,Vector2(0,0),skill_hits)

func ultimate2():
	var skill_hits=character_data.current_ultimate.hits
	character_ctrler.shoot(ultimate2_bullet,Vector2(80,60),0,Vector2(0,0),skill_hits)
