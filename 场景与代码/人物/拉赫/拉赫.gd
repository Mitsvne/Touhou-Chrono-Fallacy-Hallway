extends CharacterBody2D

var move_speed:int=400
var acceleration: float = 1600.0   # 加速度（像素/秒²）
var friction: float = 1200.0      # 减速度（像素/秒²）
var attack_interval:float=0.5
var skill_cd:float=3.0
var character_name:String="拉赫莱蒂"

@export var book:PackedScene

#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@onready var halo: Node2D = $光环




func _ready():
	character_ctrler.add_prop(book,Vector2(50,50))
	#get_parent().add_child.call_deferred(new_book)
	#get_parent().add_child(new_book)
	#character_ctrler.shoot(book,Vector2(0,0))
	print("4.character初始化完成:",character_name)

func _process(_delta: float) -> void:
	#print(character_main.current_state)
	if character_data.hp<=0:
		#effect_ctrler.fade_to_alpha(book,0,0.4)
		effect_ctrler.fade_to_alpha(halo,0,0.4)
		#book.modulate.a=0.0
		#halo.modulate.a=0.0

func book_attack():
	character_ctrler.get_prop("刻印之卷").prop_ctrler.jump_to_frame("攻击激光",0)
