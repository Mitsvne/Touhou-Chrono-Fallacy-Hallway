extends SkillNode
## 追踪弹幕连发 —— 间隔发射多枚追踪弹

@export var bullet: PackedScene
@export var count: int = 5
@export var interval: float = 0.2

func execute() -> void:
	if anplayer and not anim_name.is_empty() and anplayer.has_animation(anim_name):
		anplayer.play(anim_name)
		await anplayer.animation_finished
	else:
		fire()
	finished.emit()


func fire() -> void:
	for i in range(count):
			character_ctrler.shoot(bullet, Vector2.ZERO)
			if i < count - 1:
				await get_tree().create_timer(interval, false).timeout

func book_attack() -> void:
	character_ctrler.get_prop("刻印之卷").prop_ctrler.jump_to_frame("攻击激光", 0)
