extends Control
@export var 拉赫: AnimatedSprite2D



func _ready() -> void:
	拉赫.modulate.a = 0
	move_character_with_float(拉赫, Vector2(96, -62), Vector2(96, 219), 1.5)
	pass




func move_character_with_float(character: AnimatedSprite2D, initial_position: Vector2, target_position: Vector2, animation_length: float) -> void:
	character.position = initial_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(character, "position", target_position, animation_length)
	tween.tween_property(character, "modulate:a", 1.0, animation_length * 0.5)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
