extends GameState

var next_scene_path: String = ""
var next_state_name: String = "局内正常"

func enter() -> void:
	InputManager.is_gameplay_locked = true
	get_tree().paused = false
	var target = next_state_name  # 在 await 前保存，防止 exit() 重置
	if next_scene_path != "":
		SceneTransition.change_scene_with_fade(next_scene_path)
		await SceneTransition.transition_finished
	manager.change_state(target)

func exit() -> void:
	next_scene_path = ""
	next_state_name = "局内正常"
