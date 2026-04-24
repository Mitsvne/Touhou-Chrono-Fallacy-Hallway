extends CharacterBody2D

var move_speed:int=400
var acceleration: float = 1600.0   # 加速度（像素/秒²）
var friction: float = 1200.0      # 减速度（像素/秒²）
var attack_interval:float=0.5
var skill_cd:float=3.0
var character_name:String="拉赫莱蒂"

@export var book:PackedScene
@export var attack_bullet1:PackedScene
@export var warning_line:PackedScene
#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@onready var halo: Node2D = $光环

func _ready():
	character_ctrler.add_prop(book,Vector2(50,50))
	print("4.character初始化完成:",character_name)

func _physics_process(_delta: float) -> void:
	pass

func skill1():
	character_ctrler.add_warning_line(warning_line,Vector2(50,0))
	character_ctrler.add_warning_line(warning_line,Vector2(50,100))
	character_ctrler.add_warning_line(warning_line,Vector2(50,-100))
	character_ctrler.add_warning_line(warning_line,Vector2(50,200))
	character_ctrler.add_warning_line(warning_line,Vector2(50,-200))
	await get_tree().create_timer(1.0).timeout
	effect_ctrler.shake_once(1,1)
	#effect_ctrler.flash(0.2,Color(1.0, 1.0, 1.0, 0.392))
	character_ctrler.shoot(attack_bullet1,Vector2(-100,0))
	character_ctrler.shoot(attack_bullet1,Vector2(-100,100))
	character_ctrler.shoot(attack_bullet1,Vector2(-100,-100))
	character_ctrler.shoot(attack_bullet1,Vector2(-100,200))
	character_ctrler.shoot(attack_bullet1,Vector2(-100,-200))


func book_attack():
	character_ctrler.get_prop("刻印之卷").prop_ctrler.jump_to_frame("攻击激光",0)
