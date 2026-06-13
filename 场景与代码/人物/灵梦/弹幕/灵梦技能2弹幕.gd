extends Bullet

@export var audio: AudioStream

@onready var sprite1: Sprite2D = $图形1
@onready var sprite2: Sprite2D = $图形2

func init() -> void:
	AudioManager.play_sfx(audio,-8)
	effect_ctrler.start_shadow(sprite1,Color(1.0, 1.0, 1.0, 1.0),0.05,0.2)
	effect_ctrler.start_shadow(sprite2,Color(1.0, 1.0, 1.0, 1.0),0.05,0.2)
	bullet_ctrler.start_move_forward(600,-100)
	await get_tree().create_timer(2, false).timeout
	queue_free()
