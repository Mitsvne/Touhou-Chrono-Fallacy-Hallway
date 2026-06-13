extends CanvasLayer

@export var continue_button: Button

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	continue_button.grab_focus()
	layer+=1

func init():
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	var ps = GameStateManager.states.get(GameStateManager.STATE_PAUSED)
	GameStateManager.change_state(ps.get_return_state() if ps else GameStateManager.STATE_PLAYING)

func _on_reset_pressed() -> void:
	var tree = get_tree()
	GameStateManager.transition_to(GameStateManager.STATE_OPENING, tree.current_scene.scene_file_path)

func _on_back_to_level_pressed() -> void:
	var ps = GameStateManager.states.get(GameStateManager.STATE_PAUSED)
	if ps: ps.destroy_ui()
	GameStateManager.purge_in_game_history()
	GameStateManager.transition_to(GameStateManager.STATE_LEVEL_SEL,"res://场景与代码/ui场景/关卡选择页面/关卡选择.tscn")

func _on_back_to_menu_pressed() -> void:
	var ps = GameStateManager.states.get(GameStateManager.STATE_PAUSED)
	if ps: ps.destroy_ui()
	GameStateManager.purge_in_game_history()
	GameStateManager.transition_to(GameStateManager.STATE_MAIN_MENU,"res://场景与代码/ui场景/主菜单页面/菜单.tscn")

func _on_character_pressed() -> void:
	# record_history=false 不记录暂停，使返回时直接回到正常
	GameStateManager.transition_to(GameStateManager.STATE_CHARACTER, "res://场景与代码/ui场景/人物界面/人物界面.tscn", false)

func _on_settings_pressed() -> void:
	GameStateManager.transition_to(GameStateManager.STATE_SETTINGS,"res://场景与代码/ui场景/设置页面/设置场景.tscn")
