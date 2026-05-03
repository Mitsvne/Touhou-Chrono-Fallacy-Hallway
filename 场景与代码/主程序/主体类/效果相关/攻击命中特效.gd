extends Node2D

@export var ansprite: AnimatedSprite2D
@export var anplayer: AnimationPlayer

var attack_anim_map := {
	1: "轻击1",
	2: "中击1",
	3: "重击1",
	4: "终结"
	# 可继续扩展
}

##播放动画函数
func set_attack_effect(attack_type:int,target: Vector2):
	rotation=randf_range(0.0, 360.0)
	global_position = target
	if attack_anim_map.has(attack_type):
		var an_name = attack_anim_map[attack_type]
		anplayer.play(an_name)
		await anplayer.animation_finished
		queue_free()
	else:
		push_warning("未找到 attack_type ", attack_type, " 对应的攻击动画")
		
##攻击停顿函数
func set_hitstop(T: float = 0.1):
	Engine.time_scale = 0.1
	await get_tree().create_timer(T, true, false, true).timeout
	Engine.time_scale = 1.0

# 获取两个 Area2D 相交区域内的一个随机点（均匀分布）
func get_random_point_in_overlap(area_a: Area2D, area_b: Area2D) -> Variant:
	# 获取两个区域的多边形表示（全局坐标）
	var polys_a = _get_area_polygons(area_a)
	var polys_b = _get_area_polygons(area_b)
	if polys_a.is_empty() or polys_b.is_empty():
		return area_b.global_position
	# 计算所有多边形对之间的交集
	var intersection_polygons: Array[PackedVector2Array] = []
	for pa in polys_a:
		for pb in polys_b:
			var inter = Geometry2D.intersect_polygons(pa, pb)
			if not inter.is_empty():
				intersection_polygons.append_array(inter)
	if intersection_polygons.is_empty():
		return area_b.global_position
	# 从所有相交多边形中随机选一个（如果多个不相连的区域）
	var target_poly = intersection_polygons[randi() % intersection_polygons.size()]
	# 在该多边形内生成随机点（简单实现：包围盒内采样 + 点包含测试）
	return _get_random_point_in_polygon(target_poly, 30)  # 最多尝试30次

# 在多边形内生成随机点（简单 Monte Carlo）
func _get_random_point_in_polygon(poly: PackedVector2Array, max_attempts: int) -> Vector2:
	var bounds = _polygon_bounds(poly)
	for _i in max_attempts:
		var p = Vector2(randf_range(bounds.position.x, bounds.end.x),
						randf_range(bounds.position.y, bounds.end.y))
		if Geometry2D.is_point_in_polygon(p, poly):
			return p
	# 保底返回多边形重心（或第一个顶点）
	return _polygon_centroid(poly)

# 辅助：多边形重心（用于保底）
func _polygon_centroid(poly: PackedVector2Array) -> Vector2:
	var center = Vector2.ZERO
	for p in poly:
		center += p
	return center / poly.size()

# 辅助：计算多边形包围盒
func _polygon_bounds(poly: PackedVector2Array) -> Rect2:
	var min_x = poly[0].x
	var max_x = min_x
	var min_y = poly[0].y
	var max_y = min_y
	for p in poly:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

# 辅助：获取 Area2D 所有碰撞形状的全局多边形（支持矩形、凸多边形、圆形）
func _get_area_polygons(area: Area2D) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	for child in area.get_children():
		if child is CollisionShape2D and child.shape:
			var shape = child.shape
			var shape_transform  = child.global_transform
			var poly: PackedVector2Array
			if shape is RectangleShape2D:
				var extents = shape.size / 2
				var rect = PackedVector2Array([
					Vector2(-extents.x, -extents.y),
					Vector2( extents.x, -extents.y),
					Vector2( extents.x,  extents.y),
					Vector2(-extents.x,  extents.y)
				])
				poly = shape_transform  * rect
			elif shape is ConvexPolygonShape2D:
				poly = shape_transform  * shape.points
			elif shape is CircleShape2D:
				var radius = shape.radius
				var points = PackedVector2Array()
				var segments = 32
				for i in range(segments):
					var angle = i * TAU / segments
					points.append(Vector2(cos(angle), sin(angle)) * radius)
				poly = shape_transform  * points
			# 其他形状（胶囊、线段等）可自行扩展
			if not poly.is_empty():
				result.append(poly)
	return result
