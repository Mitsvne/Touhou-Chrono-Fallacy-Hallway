extends Node2D

@export var line2d: Line2D
@export var max_points: int = 30             # 最大点数（硬上限）
@export var min_distance: float = 10.0       # 最小生成间距（像素）
@export var trail_lifetime: float = 0.5      # 每个点的生命周期（秒）
@export var speed_threshold: float = 100.0    # 速度阈值（像素/秒），低于此速度不生成点

var last_position: Vector2
var point_times: Array = []                  # 存储每个点的创建时间（毫秒）
var last_generated_position: Vector2         # 上一次成功生成点时的位置

func _ready():
	if line2d:
		line2d.clear_points()
		last_position = global_position
		last_generated_position = global_position
	else:
		print("错误：请在检查器中指定Line2D节点。")

func _physics_process(delta: float) -> void:
	if not line2d:
		return
	var current_pos = global_position
	# 1. 计算当前帧的瞬时速度（像素/秒）
	var speed = last_position.distance_to(current_pos) / delta
	# 2. 只有速度达到阈值，才考虑生成新点
	if speed >= speed_threshold:
		# 基于上一次“生成点”的位置计算距离，避免低速移动积累的偏移
		if last_generated_position.distance_to(current_pos) >= min_distance:
			_add_point(current_pos)
			last_generated_position = current_pos
	# 3. 无论是否生成点，都要更新 last_position 用于下一帧的速度计算
	last_position = current_pos
	# 4. 移除生命周期结束的点
	_remove_expired_points()

func _add_point(pos: Vector2):
	line2d.add_point(pos)
	point_times.append(Time.get_ticks_msec())
	# 硬上限保护
	if line2d.get_point_count() > max_points:
		line2d.remove_point(0)
		point_times.pop_front()

func _remove_expired_points():
	if trail_lifetime <= 0 or point_times.is_empty():
		return
	var current_time = Time.get_ticks_msec()
	var expire_time_ms = trail_lifetime * 1000.0
	while not point_times.is_empty():
		var age_ms = current_time - point_times[0]
		if age_ms >= expire_time_ms:
			line2d.remove_point(0)
			point_times.pop_front()
		else:
			break
