extends Bullet

@export var audio: AudioStream

func init() -> void:
	AudioManager.play_sfx(audio,-5)
	bullet_ctrler.start_move_forward(600)
	await get_tree().create_timer(2, false).timeout
	queue_free()
