extends Control

func _ready() -> void:
	pass

func _on_level1_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://场景与代码/主程序/Main.tscn")
	#get_tree().change_scene_to_file("res://场景与代码/主程序/Main.tscn")


func _on_back_pressed() -> void:
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
	#SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
