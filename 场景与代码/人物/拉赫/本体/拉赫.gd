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
@export var shine_star:PackedScene
@export var warning_line:PackedScene

@onready var halo: Node2D = $VisualNode/光环
@onready var shoot_audio: AudioStreamPlayer = $音效/弹幕发射音效
@onready var fire_audio: AudioStreamPlayer = $音效/火焰弹幕音效



func _ready():
	#await get_tree().process_frame
	character_ctrler.add_prop(book,Vector2(0,-50))
	print("4.character初始化完成:",character_name)

func _physics_process(_delta: float) -> void:
	pass


func add_line():
	character_data.mp+=100
	var current_position=self.global_position
	character_ctrler.add_warning_line(current_position,Vector2(0,0),0)

## 弹幕网横向
func skill1():
	var current_position=self.global_position
	var current_rotation=0
	character_ctrler.add_warning_line(current_position,Vector2(-300,0),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,100),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,-100),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,200),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,-200),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,400),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,-400),current_rotation)
	await get_tree().create_timer(1.0, false).timeout
	effect_ctrler.shake_once(Vector2(1,1))
	character_ctrler.shoot(attack_bullet1,Vector2(-300,0),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,100),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,-100),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,200),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,-200),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,400),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,-400),current_rotation,current_position)

## 弹幕网竖向
func skill2():
	character_data.mp+=100
	var current_position=self.global_position
	var current_rotation=90
	character_ctrler.add_warning_line(current_position,Vector2(0,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(100,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-100,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(200,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-200,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(300,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-300,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(400,-300),current_rotation)
	character_ctrler.add_warning_line(current_position,Vector2(-400,-300),current_rotation)
	await get_tree().create_timer(1.0, false).timeout
	effect_ctrler.shake_once(Vector2(1,1))
	character_ctrler.shoot(attack_bullet1,Vector2(0,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(100,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-100,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(200,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-200,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(300,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-300,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(400,-300),current_rotation,current_position)
	character_ctrler.shoot(attack_bullet1,Vector2(-400,-300),current_rotation,current_position)

## 追踪弹幕连发
func skill3():
	character_data.mp+=100
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

func deep_falling_star():
	character_data.mp+=100
	var current_position=self.global_position
	var angles: Array[float] = Math.random_num(10,-140,-40)
	var x: Array[float] = Math.random_num(10,-300,300,true)
	var y=50
	for i in range(angles.size()):
		character_ctrler.add_warning_line(current_position,Vector2(x[i],y),angles[i],999,1,Color(1.0, 0.463, 0.392, 0.588),0.3,0.3,0.3)
	await get_tree().create_timer(0.3, false).timeout
	fire_audio.play()
	for i in range(angles.size()):
		character_ctrler.shoot(fire_bullet, Vector2(x[i], y), angles[i], current_position)
