extends Area2D

var ishit=false

@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var hurtarea: CollisionShape2D
@export var audio: AudioStreamPlayer
@export var bullet_data: Bullet_Data
@export var bullet_ctrler: Bullet_Ctrler



func _ready():
	await get_tree().create_timer(4, false).timeout
	queue_free()

func _physics_process(_delta):
	#print($Hitbox.global_position)
	pass

func _on_hurtbox_hurt(hitbox: Hitbox, attack_data: AttackData) -> void:
	if hitbox.owner.is_in_group("bullets"):
		bullet_data.bullet_hp-=attack_data.damage
		if bullet_data.bullet_hp<=0:
			ishit=true
			hitarea.set_deferred("disabled", true)
			hurtarea.set_deferred("disabled", true)
			an.play(&"hit")
			await an.animation_finished
			await audio.finished
			queue_free()
