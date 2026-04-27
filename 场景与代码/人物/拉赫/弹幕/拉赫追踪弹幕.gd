extends Area2D

var ishit=false

@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var hurtarea: CollisionShape2D
@export var bullet_data: Bullet_Data
@export var bullet_ctrler: Bullet_Ctrler

func _ready():
	await get_tree().process_frame
	var random_y: float = randf_range(-400, 400)
	bullet_ctrler.start_move(Vector2(400,random_y),Vector2(-50,0))
	await get_tree().create_timer(0.1, false).timeout
	bullet_ctrler.start_track(bullet_ctrler.get_target(),600,0,400)
	await get_tree().create_timer(10, false).timeout
	bullet_ctrler.stop_track()
	await get_tree().create_timer(3, false).timeout
	queue_free()

func _physics_process(_delta):
	if ishit:
		bullet_ctrler.stop_move()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.bullet_team) and area.owner.is_in_group("characters"):
		ishit=true
		hitarea.set_deferred("disabled", true)
		hurtarea.set_deferred("disabled", true)
		an.play(&"hit")
		await an.animation_finished
		await get_tree().create_timer(0.5).timeout
		queue_free()


func _on_hurtbox_hurt(hitbox: Hitbox, attack_data: AttackData) -> void:
	if hitbox.owner.is_in_group("bullets"):
		bullet_data.bullet_hp-=attack_data.damage
		if bullet_data.bullet_hp<=0:
			ishit=true
			hitarea.set_deferred("disabled", true)
			hurtarea.set_deferred("disabled", true)
			an.play(&"hit")
			await an.animation_finished
			queue_free()
