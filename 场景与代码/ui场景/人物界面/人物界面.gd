extends Control

@export var back_button:Button

func _ready() -> void:
	back_button.grab_focus()

func _on_back_pressed() -> void:
	 # 跳过历史中的"暂停"，直接回到"正常"
	while not GameStateManager.history_stack.is_empty():
		var entry = GameStateManager.history_stack.back()
		if entry["state"] == "暂停":
			GameStateManager.history_stack.pop_back()
		else:
			break
	GameStateManager.go_back()
