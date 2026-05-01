extends Area2D

var ishit=false

@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var bullet_data: Bullet_Data
@export var bullet_ctrler: Bullet_Ctrler
@export var effect_ctrler: Effect_Ctrler
@export var audio: AudioStreamPlayer

func _ready():
	await get_tree().process_frame #等一帧，其他类初始完成
	bullet_ctrler.start_move_forward(400,-100)
	await get_tree().create_timer(0.1, false).timeout
	bullet_ctrler.start_track(bullet_ctrler.get_target(),600,0,100)
	await get_tree().create_timer(5, false).timeout
	bullet_ctrler.stop_track()
	await get_tree().create_timer(3, false).timeout
	queue_free()

func _process(_delta):
	if(ishit):
		bullet_ctrler.stop_move()
		
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.bullet_team) and area.owner.is_in_group("characters"):
		ishit=true
		hitarea.set_deferred("disabled", true)
		#audio.play()
		effect_ctrler.shake_once(Vector2(2,2))
		an.play(&"hit")
		await an.animation_finished
		queue_free()
