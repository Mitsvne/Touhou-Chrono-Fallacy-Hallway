extends Bullet

@export var audio: AudioStream

func init() -> void:
	AudioManager.play_sfx(audio)
	var random_y: float = randf_range(-400, 400)
	bullet_ctrler.start_move(Vector2(400,random_y),Vector2(-50,0))
	await get_tree().create_timer(0.1, false).timeout
	bullet_ctrler.start_track(bullet_ctrler.get_target(),600,0,400)
	await get_tree().create_timer(3, false).timeout
	bullet_ctrler.stop_track()
	await get_tree().create_timer(3, false).timeout
	queue_free()
