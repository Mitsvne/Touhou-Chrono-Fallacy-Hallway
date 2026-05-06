extends CanvasLayer

var result:String      #结算结果，主程序给出

@export var label: Label

func set_result(text: String) -> void:
	result = text
	if label:
		label.text = "退治" + result

func _ready() -> void:
	GameState.set_result(true)

func _exit_tree() -> void:
	# 离开场景树时（包括重置、返回、或手动移除）恢复正常状态
	GameState.set_result(false)

## 重置关卡按钮
func _on_reset_pressed() -> void:
	GameState.set_result(false)
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().reload_current_scene()

## 返回标题按钮
func _on_return_pressed() -> void:
	GameState.set_result(false)
	get_tree().paused = false
	SceneTransition.change_scene_with_fade("res://场景与代码/ui场景/主菜单页面/菜单.tscn")
