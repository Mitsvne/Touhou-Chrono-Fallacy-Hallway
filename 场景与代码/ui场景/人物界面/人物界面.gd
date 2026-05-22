extends Control

@export var back_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.grab_focus()


func _on_back_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/关卡选择页面/关卡选择.tscn")
