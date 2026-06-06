extends GameState

func enter() -> void:
	InputManager.is_gameplay_locked = false
	get_tree().paused = false
