extends CharacterState
## 移动 —— 人物自由移动状态
class_name MoveState


func enter(_prev: CharacterState = null) -> void:
	if machine and machine.character_main:
		machine.character_main.move_animation()


func physics_update(_delta: float) -> void:
	if machine and machine.character_main:
		machine.character_main.move_animation()
		machine.character_main.fire_bullet()


func get_next_state() -> String:
	# 检查技能/必杀/冲刺输入（与 IdleState 共享逻辑）
	var special = machine.check_special_inputs()
	if special != "":
		return special

	# 无方向键 → 常态
	if not InputManager.is_action_pressed("move_left") and not InputManager.is_action_pressed("move_right"):
		return "IdleState"

	return ""
