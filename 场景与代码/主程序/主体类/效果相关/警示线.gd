extends Node2D

@export var anplayer: AnimationPlayer
@export var line: Line2D

func _ready() -> void:
	pass

## 设置线段长度（起点固定，终点沿原方向移动）
func set_length(new_length: float) -> void:
	if line.points.size() < 2:
		return
	var start: Vector2 = line.points[0]
	var end: Vector2 = line.points[1]
	var dir: Vector2 = end - start
	if dir.length() == 0:
		return  # 无法确定方向
	# 归一化方向并计算新终点
	var new_end = start + dir.normalized() * new_length
	line.set_point_position(1, new_end)

## 设置起点位置
func set_start_point(new_start: Vector2) -> void:
	if line.points.size() < 2:
		return
	line.set_point_position(0, new_start)

## 设置终点位置
func set_end_point(new_end: Vector2) -> void:
	if line.points.size() < 2:
		return
	line.set_point_position(1, new_end)

## 设置颜色
func set_color(new_color: Color) -> void:
	line.default_color = new_color
	line.gradient = null   # 确保纯色生效

## 设置宽度
func set_width(new_width: float) -> void:
	line.width = new_width

## 动画函数
func line_animate(target_length: float,grow_time: float = 0.5,keep_time: float = 0.5,shrink_time: float = 0.3) -> void:
	# 初始化状态
	#set_length(0.0)               # 从 0 开始
	line.modulate = Color.WHITE        # 重置透明度
	var tween = create_tween()
	# 1. 长度增长
	tween.tween_method(set_length, 0.0, target_length, grow_time)
	tween.tween_interval(keep_time)
	# 2. 变细 + 透明（同时进行）
	tween.tween_property(line, "width", 0.0, shrink_time)
	tween.parallel().tween_property(line, "modulate:a", 0.0, shrink_time)
	tween.tween_callback(queue_free)
