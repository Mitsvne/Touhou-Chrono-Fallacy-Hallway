extends Area2D

var ishit=false
var team:String

@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var bullet_ctrler: Bullet_Ctrler
@export var effect_ctrler: Effect_Ctrler

func _ready():
	an.play("start")
	await an.animation_finished
	an.play("loop")
	await get_tree().create_timer(2).timeout
	an.play("end")
	await an.animation_finished
	queue_free()

func _physics_process(_delta):
	pass
