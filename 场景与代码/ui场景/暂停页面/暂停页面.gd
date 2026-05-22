extends CanvasLayer

@export var continue_button: Button

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	visible = false
	GameState.state_changed.connect(_on_game_state_changed)

func _input(event):
	if event.is_action_pressed(&"pause"):
		match GameState.current_state:
			GameState.State.正常:
				GameState.set_pause(true)
			GameState.State.暂停:
				GameState.set_pause(false)

func _on_game_state_changed(new_state):
	# 根据状态同步界面和场景树暂停
	match new_state:
		GameState.State.正常:
			visible = false
			get_tree().paused = false
		GameState.State.暂停:
			visible = true
			continue_button.grab_focus()
			get_tree().paused = true
		GameState.State.结算:
			# 结算时需要隐藏暂停界面（如果它开着）
			if visible:
				visible = false
			# 不需要动paused，由结算场景管理
		_:
			pass

func _on_continue_pressed() -> void:
	GameState.set_pause(false)

func _on_reset_pressed() -> void:
	GameState.set_pause(false)
	await get_tree().process_frame
	get_tree().reload_current_scene()

func _on_back_to_level_pressed() -> void:
	GameState.set_pause(false)
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/关卡选择页面/关卡选择.tscn")

func _on_back_to_menu_pressed() -> void:
	GameState.set_pause(false)
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
