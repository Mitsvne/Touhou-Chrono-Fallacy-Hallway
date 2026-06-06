extends CanvasLayer

@export var continue_button: Button

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	continue_button.grab_focus()
	layer+=1

func init():
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	GameStateManager.change_state("正常")

func _on_reset_pressed() -> void:
	await get_tree().process_frame
	get_tree().reload_current_scene()

func _on_back_to_level_pressed() -> void:
	GameStateManager.transition_to("关卡选择","res://场景与代码/ui场景/关卡选择页面/关卡选择.tscn")

func _on_back_to_menu_pressed() -> void:
	GameStateManager.transition_to("主菜单","res://场景与代码/ui场景/主菜单页面/菜单.tscn")

func _on_character_pressed() -> void:
	GameStateManager.transition_to("人物面板","res://场景与代码/ui场景/人物界面/人物界面.tscn")

func _on_settings_pressed() -> void:
	GameStateManager.transition_to("设置","res://场景与代码/ui场景/设置页面/设置场景.tscn")
