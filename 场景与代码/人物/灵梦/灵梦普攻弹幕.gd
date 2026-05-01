extends Area2D

var ishit=false

@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var hurtarea: CollisionShape2D
@export var bullet_data: Bullet_Data
@export var bullet_ctrler: Bullet_Ctrler

func _ready():
	await get_tree().process_frame
	var target=bullet_ctrler.get_target().global_position
	#bullet_ctrler.start_move_forward(400)
	bullet_ctrler.start_move_towards(target,400,-10, -5, 5)
	await get_tree().create_timer(2, false).timeout
	queue_free()

func _physics_process(_delta):
	if(ishit):
		bullet_ctrler.stop_move()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.bullet_team) and area.owner.is_in_group("characters"):
		ishit=true
		bullet_data.get_bullet_owner().character_data.mp+=2
		hitarea.set_deferred("disabled", true)
		hurtarea.set_deferred("disabled", true)
		an.play(&"hit")
		await an.animation_finished
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
