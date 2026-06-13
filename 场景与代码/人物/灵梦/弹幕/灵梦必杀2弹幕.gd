extends Bullet

@onready var hitbox2: Hitbox = $Hitbox2

func init() -> void:
	await anplayer.animation_finished
	queue_free()

func init_damage():
	hitbox.attack_data.damage=_calculate_damage(hitbox)
	hitbox2.attack_data.damage=_calculate_damage(hitbox2)
