extends Control

@export var audio_pressed: AudioStreamPlayer
@export var audio_entered: AudioStreamPlayer
@export var carousel_menu: Control

func _ready() -> void:
	#获取所有按钮节点，连接信号
	AudioManager.play_bgm(preload("res://素材/音频素材/bgm/19 - Where The Winds Roam.mp3"), 0.5, -6.0)
	var controls = get_tree().get_nodes_in_group("selectable_control")
	for control in controls:
		control.focus_entered.connect(control_entered)

## 控件聚焦时
func control_entered():
	audio_entered.play()

func _on_back_pressed() -> void:
	audio_pressed.play()
	GameStateManager.transition_to(GameStateManager.STATE_MAIN_MENU,"res://场景与代码/ui场景/主菜单页面/菜单.tscn")
	#GameStateManager.go_back([GameStateManager.STATE_MAIN_MENU])

func _on_character_pressed() -> void:
	audio_pressed.play()
	GameStateManager.transition_to(GameStateManager.STATE_CHARACTER,"res://场景与代码/ui场景/人物界面/人物界面.tscn")

func _on_level1_pressed() -> void:
	audio_pressed.play()
	GameStateManager.transition_to(GameStateManager.STATE_OPENING,"res://场景与代码/关卡/关卡1.tscn")

func _on_level2_pressed() -> void:
	audio_pressed.play()
	GameStateManager.transition_to(GameStateManager.STATE_OPENING,"res://场景与代码/关卡/关卡2.tscn")
