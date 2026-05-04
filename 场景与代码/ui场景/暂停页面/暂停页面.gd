extends CanvasLayer

var is_paused = false
@export var continue_button: Button

func _input(event):
	if event.is_action_pressed(&"pause"):
		pause()

func pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	visible = is_paused
	continue_button.grab_focus()

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	visible = is_paused

func _on_continue_pressed() -> void:
	pause()

func _on_reset_pressed() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().reload_current_scene()
	
func _on_return_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
	#get_tree().change_scene_to_file("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
