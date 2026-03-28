extends CharacterBody2D

var move_speed:int=400
var acceleration: float = 1600.0   # 加速度（像素/秒²）
var friction: float = 1200.0      # 减速度（像素/秒²）
var attack_interval:float=0.5
var skill_cd:float=15.0
var character_name:String="拉赫莱蒂"
var team:String

@export var attack_bullet:PackedScene
@export var bullet2:PackedScene
@export var bullet3:PackedScene
@export var damage_number:PackedScene

@onready var anplayer: AnimationPlayer = $动画

#控制器导入
@onready var character_main: Character_Main = $class/Character_Main
@onready var character_data: Character_Data = $class/Character_Data
@onready var character_ctrler: Character_Ctrler = $class/Character_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler

func _ready():
	character_data.hp_max=1000
	character_data.hp=1000
	print(character_name,"character初始化完成")

func _process(_delta: float) -> void:
	pass
