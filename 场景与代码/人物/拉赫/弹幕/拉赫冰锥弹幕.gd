extends Bullet

@onready var particle: GPUParticles2D = $粒子

func init() -> void:
	bullet_ctrler.start_move_forward(200,-100)
	await get_tree().create_timer(3, false).timeout
	particle.emitting=false
	await get_tree().create_timer(1, false).timeout
	queue_free()

func hit() -> void:
	pass
