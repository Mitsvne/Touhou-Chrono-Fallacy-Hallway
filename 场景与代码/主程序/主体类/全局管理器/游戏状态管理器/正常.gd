extends GameState

func enter() -> void:
	# 恢复游戏逻辑与操作
	InputManager.is_gameplay_locked = false
	get_tree().paused = false
	manager.history_stack.clear()

func update(_delta: float) -> void:
	# 局内随时监听暂停键
	if InputManager.is_action_just_pressed("pause"):
		manager.change_state("暂停")
