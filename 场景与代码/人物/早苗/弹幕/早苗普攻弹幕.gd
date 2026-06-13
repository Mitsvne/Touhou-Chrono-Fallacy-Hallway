extends Bullet

@export var audio: AudioStream

func init():
	AudioManager.play_sfx(audio,-5)
	var target=bullet_ctrler.get_target().global_position
	bullet_ctrler.start_move_towards(target,600,-10, -5, 5)
	await get_tree().create_timer(2, false).timeout
	queue_free()
