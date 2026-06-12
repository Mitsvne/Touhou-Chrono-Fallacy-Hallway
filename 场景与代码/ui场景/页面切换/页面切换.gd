extends CanvasLayer

signal faded_out
signal faded_in
signal transition_finished

@onready var animation_player: AnimationPlayer = $动画
@onready var color_rect: ColorRect = $黑屏

## 用来保存上一个场景的路径
var previous_scene_path: String = ""

func _ready() -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 避免遮罩阻挡鼠标点击
	animation_player.process_mode = Node.PROCESS_MODE_ALWAYS  # 防止被暂停中断淡入

## 执行完整的场景切换流程：淡出 → 切换场景 → 淡入
func change_scene_with_fade(target_scene_path: String) -> void:
	previous_scene_path = get_tree().current_scene.scene_file_path
	animation_player.play("淡出")
	await animation_player.animation_finished
	faded_out.emit()
	#print("场景切换")
	get_tree().change_scene_to_file(target_scene_path)
	await get_tree().process_frame   # 等待一帧，确保界面已加载
	animation_player.play("淡入")
	transition_finished.emit()
	await animation_player.animation_finished
	faded_in.emit()

## 黑屏淡出
func fade_out() -> void:
	animation_player.play("淡出")
	await animation_player.animation_finished
	faded_out.emit()

## 黑屏淡入
func fade_in() -> void:
	animation_player.play("淡入")
	await animation_player.animation_finished
	faded_in.emit()
	
## 返回上一个场景
func go_back() -> void:
	if previous_scene_path != "":
		change_scene_with_fade(previous_scene_path)
	else:
		push_warning("没有找到上一个场景的记录！")
