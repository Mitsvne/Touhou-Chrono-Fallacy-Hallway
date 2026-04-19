extends Area2D
var ishit=false
var speed:int=500
var angle:int=200

@export var Sprite: AnimatedSprite2D
@export var an: AnimationPlayer
@export var audio: AudioStreamPlayer
@export var hitarea: CollisionShape2D
@export var hurtarea: CollisionShape2D
@export var bullet_data: Bullet_Data
@export var effect_ctrler: Effect_Ctrler
@export var bullet_ctrler: Bullet_Ctrler

func _ready():
	bullet_ctrler.apply_gravity(true)
	await get_tree().create_timer(2, false).timeout
	queue_free()

func _process(_delta: float) -> void:
	if(ishit):
		bullet_ctrler.stop_move()
	else:
		an.play(&"loop")
		bullet_ctrler.start_move(Vector2(cos(angle) * speed,sin(angle) * speed))

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.bullet_team) and area.owner.is_in_group("characters"):
		ishit=true
		effect_ctrler.shake_once(2,2)
		bullet_data.get_bullet_owner().character_data.mp+=10
		hitarea.set_deferred("disabled", true)
		hurtarea.set_deferred("disabled", true)
		an.play(&"hit")
		audio.play()
		await an.animation_finished
		await audio.finished
		queue_free()


func _on_hurtbox_hurt(hitbox: Hitbox, attack_data: AttackData) -> void:
	if hitbox.owner.is_in_group("bullets"):
		bullet_data.bullet_hp-=attack_data.damage
		if bullet_data.bullet_hp<=0:
			ishit=true
			hitarea.set_deferred("disabled", true)
			hurtarea.set_deferred("disabled", true)
			an.play(&"hit")
			audio.play()
			await an.animation_finished
			await audio.finished
			queue_free()
