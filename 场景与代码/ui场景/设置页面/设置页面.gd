extends Control
@export var 拉赫: AnimatedSprite2D
@export var back_button:Button
@export var audio_pressed: AudioStreamPlayer
@export var audio_entered: AudioStreamPlayer

func _ready() -> void:
	AudioManager.play_bgm(preload("res://素材/音频素材/bgm/04 - Silent Forest.mp3"), 0.5, -6.0)
	拉赫.modulate.a = 0
	move_character_with_float(拉赫, Vector2(96, -62), Vector2(96, 219), 1.5)
	var controls = get_tree().get_nodes_in_group("selectable_control")
	for control in controls:
		control.focus_entered.connect(control_entered)
	back_button.grab_focus()

## 移动动画效果
func move_character_with_float(character: AnimatedSprite2D, initial_position: Vector2, target_position: Vector2, animation_length: float) -> void:
	character.position = initial_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(character, "position", target_position, animation_length)
	tween.tween_property(character, "modulate:a", 1.0, animation_length * 0.5)

## 控件聚焦时
func control_entered():
	audio_entered.play()

func _on_back_pressed() -> void:
	audio_pressed.play()
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
	#get_tree().change_scene_to_file("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
