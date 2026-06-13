extends GameState

func _ready() -> void:
	is_in_game = true  # _ready 设，防止 tscn 反序列化覆盖

func enter() -> void:
	# 恢复游戏逻辑与操作
	InputManager.is_gameplay_locked = false
	get_tree().paused = false
	manager.purge_in_game_history()  # 只清局内历史，保留局外
