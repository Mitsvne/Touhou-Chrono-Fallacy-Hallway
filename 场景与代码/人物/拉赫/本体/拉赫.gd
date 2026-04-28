extends CharacterBody2D

var move_speed:int=400
var acceleration: float = 1600.0   # 加速度（像素/秒²）
var friction: float = 1200.0      # 减速度（像素/秒²）
var attack_interval:float=0.5
var skill_cd:float=1.0
var character_name:String="拉赫莱蒂"

@export var book:PackedScene
@export var attack_bullet1:PackedScene
@export var attack_bullet2:PackedScene
@export var warning_line:PackedScene
#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@onready var halo: Node2D = $光环
@onready var shoot_audio: AudioStreamPlayer = $音效/弹幕发射音效


func _ready():
	character_ctrler.add_prop(book,Vector2(50,50))
	print("4.character初始化完成:",character_name)

func _physics_process(_delta: float) -> void:
	pass

func skill1():
	var current_position=self.global_position
	var current_rotation=0
	character_ctrler.add_warning_line(warning_line,Vector2(50,0))
	character_ctrler.add_warning_line(warning_line,Vector2(50,100))
	character_ctrler.add_warning_line(warning_line,Vector2(50,-100))
	character_ctrler.add_warning_line(warning_line,Vector2(50,200))
	character_ctrler.add_warning_line(warning_line,Vector2(50,-200))
	character_ctrler.add_warning_line(warning_line,Vector2(50,300))
	character_ctrler.add_warning_line(warning_line,Vector2(50,-300))
	character_ctrler.add_warning_line(warning_line,Vector2(50,400))
	character_ctrler.add_warning_line(warning_line,Vector2(50,-400))
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

func skill2():
	character_data.mp+=100
	var current_position=self.global_position
	var current_rotation=90
	character_ctrler.add_warning_line(warning_line,Vector2(0,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(100,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(-100,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(200,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(-200,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(300,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(-300,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(400,-300),current_rotation)
	character_ctrler.add_warning_line(warning_line,Vector2(-400,-300),current_rotation)
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
