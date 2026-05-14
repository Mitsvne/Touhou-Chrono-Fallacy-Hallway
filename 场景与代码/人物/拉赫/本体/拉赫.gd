extends CharacterBody2D

#控制器导入
@export var character_ai_main: Character_AI_Main
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_input: Character_Input
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@export var bt_player: BTPlayer

var move_speed:int=400
var acceleration: float = 1600.0   # 加速度（像素/秒²）
var friction: float = 1200.0      # 减速度（像素/秒²）
var attack_interval:float=0.5
var skill_cd:float=1.0
var character_name:String="拉赫莱蒂"

@export var book:PackedScene
@export var attack_bullet1:PackedScene
@export var attack_bullet2:PackedScene
@export var fire_bullet:PackedScene
@export var ice_bullet:PackedScene
@export var shine_star:PackedScene
@export var magic_array:PackedScene
@export var magic_array2:PackedScene

@onready var halo: Node2D = $VisualNode/光环
@onready var fire_audio: AudioStreamPlayer = $音效/火焰弹幕音效
@onready var ice_audio: AudioStreamPlayer = $音效/寒冰弹幕音效

func _ready():
	#await get_tree().process_frame
	character_ctrler.add_prop(book,Vector2(0,-50))
	print("4.character初始化完成:",character_name)

func _physics_process(_delta: float) -> void:
	character_data.mp+=100
	pass


## 弹幕网
func skill1():
	var current_position=self.global_position
	for i in range(-10,11):
		print(i)
		character_ctrler.add_warning_line(current_position,Vector2(-700,100*i),0,2000)
		character_ctrler.add_warning_line(current_position,Vector2(100*i,-700),90,2000)
	await get_tree().create_timer(1.0, false).timeout
	effect_ctrler.shake_once(Vector2(1,1))
	for i in range(-10,11):
		character_ctrler.shoot(attack_bullet1,Vector2(-700,100*i),0,current_position)
		character_ctrler.shoot(attack_bullet1,Vector2(100*i,-700),90,current_position)

## 追踪弹幕连发
func skill3():
	character_ctrler.shoot(attack_bullet2,Vector2(0,0))
	await get_tree().create_timer(0.2, false).timeout
	character_ctrler.shoot(attack_bullet2,Vector2(0,0))
	await get_tree().create_timer(0.2, false).timeout
	character_ctrler.shoot(attack_bullet2,Vector2(0,0))
	await get_tree().create_timer(0.2, false).timeout
	character_ctrler.shoot(attack_bullet2,Vector2(0,0))
	await get_tree().create_timer(0.2, false).timeout
	character_ctrler.shoot(attack_bullet2,Vector2(0,0))
	await get_tree().create_timer(0.2, false).timeout



func book_attack():
	character_ctrler.get_prop("刻印之卷").prop_ctrler.jump_to_frame("攻击激光",0)
	
func add_shine_star():
	character_ctrler.add_effect(shine_star,self.global_position,Vector2(0,50))

func add_magic_array():
	character_ctrler.add_effect(magic_array,self.global_position,Vector2(0,50))
	
func add_magic_array2():
	character_ctrler.add_effect(magic_array2,self.global_position,Vector2(0,0))

func deep_falling_star():
	var current_position=self.global_position
	var angles: Array[float] = Math.random_num(10,-140,-40)
	var x: Array[float] = Math.random_num(10,-300,300,true)
	var y=100
	for i in range(angles.size()):
		character_ctrler.add_warning_line(current_position,Vector2(x[i],y),angles[i],999,1,Color(1.825, 0.868, 0.742, 1.0),0.3,0.3,0.3)
	await get_tree().create_timer(0.3, false).timeout
	fire_audio.play()
	for i in range(angles.size()):
		character_ctrler.shoot(fire_bullet, Vector2(x[i], y), angles[i], current_position)

func severe_ice_prison():
	var current_position=self.global_position
	ice_audio.play()
	effect_ctrler.shake_once(Vector2(2,2),0.4)
	effect_ctrler.flash(0.4,Color(0.0, 0.875, 0.91, 0.078))
	if randi_range(0, 1) == 0:
		for i in range(0,360,20):
			character_ctrler.shoot(ice_bullet, Vector2(0, 0), i, current_position)
	else:
		for i in range(10,370,20):
			character_ctrler.shoot(ice_bullet, Vector2(0, 0), i, current_position)
