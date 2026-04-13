extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_level1_pressed() -> void:
	get_tree().change_scene_to_file("res://场景与代码/主程序/Main.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
