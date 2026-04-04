extends Camera2D
'''
# --- 配置参数 ---
@export var zoom_limit_min: float = 1.0   # 最小缩放值（镜头最远，数值越小视野越大）
@export var zoom_limit_max: float = 1.5  # 最大缩放值（镜头最近，数值越大视野越小）
@export var zoom_speed: float = 5.0       # 缩放过渡的平滑速度
@export var follow_speed: float = 10.0    # 位置跟随的平滑速度
@export var margin_px: float = 50.0       # 边缘留白（像素），防止玩家紧贴屏幕边缘

# 计算所有"player"组节点的中心点
func _get_center_of_players() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return Vector2.ZERO
	var center = Vector2.ZERO
	for player in players:
		center += player.global_position
	center /= players.size()
	return center

func _ready() -> void:
	pass

# 每帧更新相机的位置和缩放
func _process(delta: float):
	# 1. 更新位置：平滑移动到玩家们的中心点
	var target_position = _get_center_of_players()
	global_position = global_position.lerp(target_position, follow_speed * delta)
	# 2. 更新缩放：平滑调整到理想缩放值
	#var target_zoom_value = _get_desired_zoom()
	#var new_zoom = Vector2(target_zoom_value, target_zoom_value)
	#zoom = zoom.lerp(new_zoom, zoom_speed * delta)


# 计算使所有玩家都能保持在屏幕内的理想缩放值
func _get_desired_zoom() -> float:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() < 2:
		return zoom_limit_max  # 单人时，推到最近（zoom最大）
	# 1. 获取玩家之间的包围盒 (Bounding Box)
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for player in players:
		var pos = player.global_position
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	# 考虑边缘留白，扩展包围盒
	min_x -= margin_px
	max_x += margin_px
	min_y -= margin_px
	max_y += margin_px
	# 2. 计算所需宽度和高度（世界单位）
	var needed_width = max_x - min_x
	var needed_height = max_y - min_y
	# 3. 获取当前视口大小（像素）
	var viewport_size = get_viewport_rect().size
	# 4. 【修正】计算理想缩放值
	var zoom_x = viewport_size.x / needed_width
	var zoom_y = viewport_size.y / needed_height
	var desired_zoom_value = min(zoom_x, zoom_y)  # 取最小值，确保两个方向都不超出
	# 限制缩放范围并返回
	return clamp(desired_zoom_value, zoom_limit_min, zoom_limit_max)
'''
