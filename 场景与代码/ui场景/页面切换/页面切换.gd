extends CanvasLayer

signal faded_out
signal faded_in

@onready var animation_player: AnimationPlayer = $动画
@onready var color_rect: ColorRect = $黑屏

func _ready() -> void:
	# 避免遮罩阻挡点击
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# 执行完整的场景切换流程：淡出 → 切换场景 → 淡入
func change_scene_with_fade(target_scene_path: String) -> void:
	animation_player.play("淡出")
	await animation_player.animation_finished
	faded_out.emit()
	print("场景切换")
	get_tree().change_scene_to_file(target_scene_path)
	# 等待新场景的根节点就绪（下一帧），确保界面已加载
	await get_tree().process_frame
	animation_player.play("淡入")
	await animation_player.animation_finished
	faded_in.emit()

# 也可以单独提供淡出/淡入方法，供其他用途调用
func fade_out() -> void:
	animation_player.play("淡出")
	await animation_player.animation_finished
	faded_out.emit()

func fade_in() -> void:
	animation_player.play("淡入")
	await animation_player.animation_finished
	faded_in.emit()
