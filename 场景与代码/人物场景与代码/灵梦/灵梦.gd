extends CharacterBody2D

var move_speed:int=300
var attack_interval:float=0.3
var skill_cd:float=3.0
var character_name:String="博丽灵梦"
enum State{常态,技能1,必杀1}
var team:String

@export var attack_bullet:PackedScene
@export var bullet2:PackedScene
@export var bullet3:PackedScene
@export var damage_number:PackedScene

@onready var anplayer: AnimationPlayer = $动画

#控制器导入
@onready var character_data: Character_Data = $class/Character_Data
@onready var character_ctrler: Character_Ctrler = $class/Character_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler


func _ready():
	character_data.hp_max=200
	character_data.hp=200
