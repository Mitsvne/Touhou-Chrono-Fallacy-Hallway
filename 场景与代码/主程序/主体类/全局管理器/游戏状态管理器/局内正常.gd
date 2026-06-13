extends GameState

func _init() -> void:
	is_in_game = true

func enter() -> void:
	# 恢复游戏逻辑与操作
	InputManager.is_gameplay_locked = false
	get_tree().paused = false
	manager.history_stack.clear()
