extends Control

@export var back_button:Button

func _ready() -> void:
	back_button.grab_focus()

func _on_back_pressed() -> void:
	GameStateManager.go_back([GameStateManager.STATE_LEVEL_SEL, GameStateManager.STATE_PLAYING, GameStateManager.STATE_OPENING])
