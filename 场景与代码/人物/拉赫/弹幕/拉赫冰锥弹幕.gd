extends Area2D

var ishit=false

@export var sprite: Sprite2D
@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var hurtarea: CollisionShape2D
@export var particle: GPUParticles2D 
@export var bullet_data: Bullet_Data
@export var bullet_ctrler: Bullet_Ctrler
@export var effect_ctrler: Effect_Ctrler

func _ready():
	await get_tree().process_frame
	bullet_ctrler.start_move_forward(200,-100)
	await get_tree().create_timer(3, false).timeout
	particle.emitting=false
	await get_tree().create_timer(1, false).timeout
	queue_free()

func _physics_process(_delta):
	if ishit:
		#bullet_ctrler.stop_move()
		pass

## 命中效果
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.bullet_team) and area.owner.is_in_group("characters"):
		ishit=true
		#hitarea.set_deferred("disabled", true)
		#hurtarea.set_deferred("disabled", true)
		#await an.animation_finished
		#queue_free()

## 被攻击命中效果
func _on_hurtbox_hurt(hitbox: Hitbox, attack_data: AttackData) -> void:
	if hitbox.owner.is_in_group("bullets"):
		bullet_data.bullet_hp-=attack_data.damage
		if bullet_data.bullet_hp<=0:
			ishit=true
			hitarea.set_deferred("disabled", true)
			hurtarea.set_deferred("disabled", true)
			await an.animation_finished
			queue_free()
