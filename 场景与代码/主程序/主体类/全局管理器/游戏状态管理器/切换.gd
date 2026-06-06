extends GameState

var next_scene_path: String = ""
var next_state_name: String = "正常"

func enter() -> void:
	InputManager.is_gameplay_locked = true
	get_tree().paused = false 
	if next_scene_path != "":
		SceneTransition.change_scene_with_fade(next_scene_path)
		await SceneTransition.transition_finished
	manager.change_state(next_state_name)

func exit() -> void:
	next_scene_path = ""
	next_state_name = "正常"
