extends Bullet

@export var audio: AudioStream

func init() -> void:
	mp=0
	AudioManager.play_sfx(audio)
	bullet_ctrler.start_move_forward(400,-100)
	await get_tree().create_timer(0.1, false).timeout
	bullet_ctrler.start_track(bullet_ctrler.get_target(),600,0,100)
	await get_tree().create_timer(5, false).timeout
	bullet_ctrler.stop_track()
	await get_tree().create_timer(3, false).timeout
	queue_free()

func hit() -> void:
	bullet_ctrler.stop_move()
	effect_ctrler.shake_once(Vector2(2,2))
	anplayer.play(&"hit")
	await anplayer.animation_finished
	queue_free()
