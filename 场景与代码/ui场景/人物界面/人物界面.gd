extends Control

@export var back_button:Button

func _ready() -> void:
	back_button.grab_focus()

func _on_back_pressed() -> void:
	GameStateManager.go_back(["关卡选择", "局内正常", "局内开场"])
