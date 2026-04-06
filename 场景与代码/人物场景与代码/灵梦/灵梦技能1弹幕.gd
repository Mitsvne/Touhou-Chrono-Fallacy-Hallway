extends Area2D
var ishit=false
var team:String
var speed:int=500
var angle:int=200

@export var Sprite: AnimatedSprite2D
@export var an: AnimationPlayer
@export var audio: AudioStreamPlayer
@export var hitarea: CollisionShape2D
@export var effect_ctrler: Effect_Ctrler
@export var bullet_ctrler: Bullet_Ctrler

func _ready():
	bullet_ctrler.apply_gravity(true)
	effect_ctrler.start_shadow(Sprite)
	await get_tree().create_timer(2).timeout
	effect_ctrler.stop_shadow()
	queue_free()

func _process(_delta: float) -> void:
	if(ishit):
		bullet_ctrler.stop_move()
	else:
		an.play(&"loop")
		bullet_ctrler.start_move(Vector2(cos(angle) * speed,sin(angle) * speed))

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(team):
		ishit=true
		hitarea.set_deferred("disabled", true)
		an.play(&"hit")
		audio.play()
		effect_ctrler.stop_shadow()
		await an.animation_finished
		await audio.finished
		queue_free()
