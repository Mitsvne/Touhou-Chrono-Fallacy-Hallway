extends Area2D

@export var speed:float=400
@export var drag:float=0
@export var mp:float=5
@export var audio: AudioStream

@onready var an: AnimationPlayer = $动画
@onready var bullet_data: Bullet_Data = $class/Bullet_Data
@onready var bullet_ctrler: Bullet_Ctrler = $class/Bullet_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler

func _ready():
	await get_tree().process_frame
	await an.animation_finished
	#await get_tree().create_timer(2, false).timeout
	queue_free()

func _physics_process(_delta):
	#不要直接删除
	pass
