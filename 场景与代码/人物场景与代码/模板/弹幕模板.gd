extends Area2D

var ishit=false
var team:String

@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var bullet_ctrler: Bullet_Ctrler
@export var effect_ctrler: Effect_Ctrler

func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()

func _physics_process(_delta):
	if(ishit):
		bullet_ctrler.stop_move()
	else:
		bullet_ctrler.start_move(Vector2(400,0))

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(team):
		ishit=true
		hitarea.set_deferred("disabled", true)
		an.play(&"hit")
		await an.animation_finished
		queue_free()
