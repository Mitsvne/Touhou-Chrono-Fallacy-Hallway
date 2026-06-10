extends CharacterState
## 常态 —— 人物待机状态
class_name IdleState


func enter(_prev: CharacterState = null) -> void:
	play_animation("常态")


func physics_update(_delta: float) -> void:
	if machine and machine.character_main:
		machine.character_main.update_direction()
		machine.character_main.fire_bullet()


func get_next_state() -> String:
	# 检查技能/必杀/冲刺输入（与 MoveState 共享逻辑）
	var special = machine.check_special_inputs()
	if special != "":
		return special

	# 方向键 → 移动
	if InputManager.is_action_pressed("move_left") or InputManager.is_action_pressed("move_right"):
		return "MoveState"

	return ""
