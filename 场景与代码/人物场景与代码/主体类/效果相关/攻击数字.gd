extends Node2D

# 显示伤害数字的 Label 节点引用
@onready var label: Label = $数字文本
# 漂浮参数
@export var float_speed: float = 50.0      # 每秒上升像素
@export var fade_duration: float = 0.8     # 淡出总时长
@export var start_scale: float = 1.0       # 初始缩放

# 设置伤害数字的内容和初始位置
func set_damage(value: int, position1: Vector2, color: Color = Color.RED) -> void:
	# 设置文本和颜色
	label.text = str(value)
	label.modulate = color
	global_position = position1 + Vector2(randf_range(-10, 10), randf_range(-5, 5))
	scale = Vector2(start_scale, start_scale)
	# 启动动画
	_animate()

func _animate() -> void:
	# 创建 Tween 并绑定到节点自身
	var tween = create_tween()
	tween.set_parallel(true)  # 允许动画同时进行
	# 向上移动动画
	var target_pos = position - Vector2(0, float_speed * fade_duration)
	tween.tween_property(self, "position", target_pos, fade_duration)
	# 淡出动画：修改 modulate 的 alpha 值
	tween.tween_property(label, "modulate:a", 0.0, fade_duration)
	# 可选：缩放动画（先放大再缩小或仅缩小）
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), fade_duration)
	# 动画结束后删除节点
	tween.finished.connect(queue_free)
