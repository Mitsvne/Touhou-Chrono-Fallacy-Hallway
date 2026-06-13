extends Bullet

@export var add_audio: AudioStream
@export var hit_audio: AudioStream

func init() -> void:
	AudioManager.play_sfx(add_audio,-6)
	var target=bullet_ctrler.get_target().global_position
	bullet_ctrler.start_move_parabola(target,0,150,0)
	await get_tree().create_timer(4, false).timeout
	queue_free()

func hit():
	bullet_ctrler.stop_move()
	anplayer.play(&"hit")
	AudioManager.play_sfx(hit_audio)
	await anplayer.animation_finished
	queue_free()
