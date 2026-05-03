extends CanvasLayer

var result:String      #结算结果，主程序给出

@export var label: Label

func _ready() -> void:
	label.text="祓除"+result

## 重置关卡按钮
func _on_reset_pressed() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().reload_current_scene()

## 返回标题按钮
func _on_return_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
