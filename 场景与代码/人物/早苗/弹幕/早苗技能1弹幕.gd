extends Bullet

@export var audio: AudioStream
@export var audio2: AudioStream

func init() -> void:
	AudioManager.play_sfx(audio,-5)
	anplayer.play("start")
	await anplayer.animation_finished
	AudioManager.play_sfx(audio2,-8)
	anplayer.play("loop")
	var target=bullet_ctrler.get_target().global_position
	bullet_ctrler.start_move_towards(target,600,-10, 10, 60)
	await get_tree().create_timer(2, false).timeout
	queue_free()
