extends SkillNode
## 严寒冰牢 —— 震屏 + 闪屏 + 360° 环形冰锥散开

@export var bullet: PackedScene
@export var angle_step: int = 20
@export var flash_color: Color = Color(0.0, 0.875, 0.91, 0.078)
@export var shake_strength: Vector2 = Vector2(2, 2)
@export var shake_duration: float = 0.4
@export var audio_player: AudioStreamPlayer
@export var magic_array: PackedScene

func execute() -> void:
	if anplayer and not anim_name.is_empty() and anplayer.has_animation(anim_name):
		anplayer.play(anim_name)
		await anplayer.animation_finished
	else:
		fire()
	finished.emit()


func fire() -> void:
	if audio_player:
		audio_player.play()
	effect_ctrler.shake_once(shake_strength, shake_duration)
	effect_ctrler.flash(shake_duration, flash_color)
	var offset := 0 if randi_range(0, 1) == 0 else 10
	var pos = agent.global_position
	for angle in range(offset, 360 + offset, angle_step):
		character_ctrler.shoot(bullet, Vector2.ZERO, angle, pos)


func add_magic_array() -> void:
	character_ctrler.add_effect(magic_array, agent.global_position, Vector2(0, 0))
