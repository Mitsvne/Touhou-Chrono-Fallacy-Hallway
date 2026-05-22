extends Control
class_name PlayerUI

var player_ui_enable:bool = false;
# res://场景与代码/ui场景/人物界面/人物界面.tscn
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	GameState.state_changed.connect(_on_game_state_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event):
	if player_ui_enable:
		if event.is_action_pressed(&"interact") || event.is_action_pressed(&"pause"):
			match GameState.current_state:
				GameState.State.背包:
					player_ui_enable = false;
					GameState.current_state = GameState.State.正常
		return
	if event.is_action_pressed(&"interact"):
		match GameState.current_state:
			GameState.State.正常:
				player_ui_enable = true;
				GameState.current_state = GameState.State.背包

func _on_game_state_changed(new_state):
	# 根据状态同步界面和场景树暂停
	match new_state:
		GameState.State.背包:
			visible = true
			get_tree().paused = true
		_:
			visible = false
			get_tree().paused = false
