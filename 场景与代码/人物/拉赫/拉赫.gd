extends CharacterBody2D

var move_speed:int=400
var acceleration: float = 1600.0   # 加速度（像素/秒²）
var friction: float = 1200.0      # 减速度（像素/秒²）
var attack_interval:float=0.5
var skill_cd:float=15.0
var character_name:String="拉赫莱蒂"

@export var attack_bullet:PackedScene
@export var bullet2:PackedScene
@export var bullet3:PackedScene

#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler
@onready var book: Node2D = $书
@onready var halo: Node2D = $光环




func _ready():
	print("4.character初始化完成:",character_name)

func _process(_delta: float) -> void:
	if character_data.hp<=0:
		effect_ctrler.fade_to_alpha(book,0,0.4)
		effect_ctrler.fade_to_alpha(halo,0,0.4)
		#book.modulate.a=0.0
		#halo.modulate.a=0.0
