extends CharacterBody2D
#控制器导入
@export var character_main: Character_Main
@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var effect_ctrler: Effect_Ctrler

var move_speed:int=400
var acceleration: float = 1600.0   # 加速度（像素/秒²）
var friction: float = 1200.0      # 减速度（像素/秒²）
var attack_interval:float=0.3
var skill_cd:float=3.0
var character_name:String="博丽灵梦"

@export var audio: AudioStreamPlayer
@export var attack_bullet:PackedScene
@export var bullet2:PackedScene
@export var bullet3:PackedScene




func _ready():
	print("4.character初始化完成:",character_name)
	
	
func _physics_process(_delta: float) -> void:
	pass



func play_audio():
	audio.play()
