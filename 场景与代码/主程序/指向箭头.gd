extends Sprite2D

@export var player: Node2D
@export var enemy: Node2D
@export var buffer_zone: float = 30.0 # 缓冲区大小，根据你敌人模型的大小来定
@export var icon_margin: float = 30.0  # 图标贴在屏幕边缘时的留白

func _process(_delta: float) -> void:
	if not player or not enemy:
		return

	var canvas_transform = get_viewport().get_canvas_transform()
	var screen_size = get_viewport_rect().size
	var enemy_screen_pos = canvas_transform * enemy.global_position
	#var player_screen_pos = canvas_transform * player.global_position
	var detection_rect = Rect2(Vector2.ZERO, screen_size).grow(buffer_zone)
	# 2. 只有当敌人的“中心点”跑出这个缓冲区时，才显示图标
	if detection_rect.has_point(enemy_screen_pos):
		visible = false
	else:
		visible = true
		# 以下逻辑保持不变：计算方向并把图标钉在屏幕边缘
		var screen_center = screen_size / 2.0
		var direction = (enemy_screen_pos - screen_center).normalized()
		# 计算图标在屏幕边缘的具体坐标
		var intersect_pos = _calculate_edge_point(screen_center, direction, screen_size, icon_margin)
		global_position = intersect_pos
		rotation = direction.angle()
		#print(rad_to_deg(rotation))

# 依然需要这个函数来保证图标准确对准边缘
func _calculate_edge_point(center: Vector2, dir: Vector2, s_size: Vector2, m: float) -> Vector2:
	var min_b = Vector2(m, m)
	var max_b = Vector2(s_size.x - m, s_size.y - m)
	var t = INF
	if dir.x > 0: t = min(t, (max_b.x - center.x) / dir.x)
	elif dir.x < 0: t = min(t, (min_b.x - center.x) / dir.x)
	if dir.y > 0: t = min(t, (max_b.y - center.y) / dir.y)
	elif dir.y < 0: t = min(t, (min_b.y - center.y) / dir.y)
	return center + dir * t
