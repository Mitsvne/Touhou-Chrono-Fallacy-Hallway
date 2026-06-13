extends Bullet

@export var audio: AudioStream

func init() -> void:
	AudioManager.play_sfx(audio)
	bullet_ctrler.start_move_forward(800,-10)
	await get_tree().create_timer(3, false).timeout
	queue_free()
