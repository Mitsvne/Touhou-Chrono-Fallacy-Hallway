extends SkillNode
## 弹幕网 —— 十字交叉弹幕 + 预警线
## 动画关键帧: _on_warning() → 画预警线, _on_fire() → 发射

@export var bullet: PackedScene
@export var half_width: int = 10
@export var spacing: float = 100.0
@export var line_length: float = 700.0
@export var bullet_speed: float = 2000

func execute() -> void:
	if anplayer and not anim_name.is_empty() and anplayer.has_animation(anim_name):
		anplayer.play(anim_name)
		await anplayer.animation_finished
	else:
		# 无动画时直接跑逻辑
		warning()
		await get_tree().create_timer(1.0, false).timeout
		fire()
	finished.emit()

func warning_and_fire():
	warning()
	await get_tree().create_timer(1.0, false).timeout
	fire()


func warning() -> void:
	var pos = agent.global_position
	for i in range(-half_width, half_width + 1):
		character_ctrler.add_warning_line(pos, Vector2(-line_length, spacing * i), 0, bullet_speed)
		character_ctrler.add_warning_line(pos, Vector2(spacing * i, -line_length), 90, bullet_speed)


func fire() -> void:
	var pos = agent.global_position
	effect_ctrler.shake_once(Vector2(1, 1))
	for i in range(-half_width, half_width + 1):
		character_ctrler.shoot(bullet, Vector2(-line_length, spacing * i), 0, pos)
		character_ctrler.shoot(bullet, Vector2(spacing * i, -line_length), 90, pos)

func book_attack() -> void:
	character_ctrler.get_prop("刻印之卷").prop_ctrler.jump_to_frame("攻击激光", 0)
