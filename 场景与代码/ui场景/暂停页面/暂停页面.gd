extends CanvasLayer

@export var continue_button: Button

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	continue_button.grab_focus()
	layer+=1

func init():
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	var ps = GameStateManager.states.get("暂停")
	GameStateManager.change_state(ps._return_state if ps else "正常")

func _on_reset_pressed() -> void:
	var ps = GameStateManager.states.get("暂停")
	var tree = get_tree()
	GameStateManager.change_state(ps._return_state if ps else "正常")
	tree.reload_current_scene()

func _on_back_to_level_pressed() -> void:
	GameStateManager.transition_to("关卡选择","res://场景与代码/ui场景/关卡选择页面/关卡选择.tscn")

func _on_back_to_menu_pressed() -> void:
	GameStateManager.transition_to("主菜单","res://场景与代码/ui场景/主菜单页面/菜单.tscn")

func _on_character_pressed() -> void:
	# 弹出历史中最近的暂停条目，使返回时跳过暂停
	var hs = GameStateManager.history_stack
	if not hs.is_empty() and hs.back()["state"] == "暂停":
		hs.pop_back()
	GameStateManager.transition_to("人物面板","res://场景与代码/ui场景/人物界面/人物界面.tscn")

func _on_settings_pressed() -> void:
	GameStateManager.transition_to("设置","res://场景与代码/ui场景/设置页面/设置场景.tscn")
