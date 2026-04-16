extends Node2D

@export var ansprite: AnimatedSprite2D
@export var anplayer: AnimationPlayer

var attack_anim_map := {
	1: "轻击1",
	2: "重击1"
	# 可继续扩展
}

##播放动画函数
func set_attack_effect(attack_type:int,target: Vector2):
	global_position = target
	if attack_anim_map.has(attack_type):
		var an_name = attack_anim_map[attack_type]
		anplayer.play(an_name)
		await anplayer.animation_finished
		queue_free()
	else:
		push_warning("未找到 attack_type ", attack_type, " 对应的攻击动画")
		
# 获取两个 Area2D 相交区域内的一个随机点（均匀分布）
func get_random_point_in_overlap(area_a: Area2D, area_b: Area2D) -> Variant:
	# 获取两个区域的多边形表示（全局坐标）
	var polys_a = _get_area_polygons(area_a)
	var polys_b = _get_area_polygons(area_b)
	if polys_a.is_empty() or polys_b.is_empty():
		return null
	# 计算所有多边形对之间的交集
	var intersection_polygons: Array[PackedVector2Array] = []
	for pa in polys_a:
		for pb in polys_b:
			var inter = Geometry2D.intersect_polygons(pa, pb)
			if not inter.is_empty():
				intersection_polygons.append_array(inter)
	if intersection_polygons.is_empty():
		return null
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

"""
##获取两个Area2D相交范围内的随机一个点
func get_random_point_in_overlap(area_a: Area2D, area_b: Area2D, max_attempts: int = 50) -> Vector2:
	var space_state = area_a.get_world_2d().direct_space_state
	# 先获取两个区域各自的粗略采样范围（可用任意一个的包围盒作为起点）
	var bounds = get_area_bounds(area_a).merge(get_area_bounds(area_b))
	for i in max_attempts:
		var p = Vector2(randf_range(bounds.position.x, bounds.end.x),
						randf_range(bounds.position.y, bounds.end.y))
		# 检查点是否同时属于两个 Area2D（忽略其他碰撞体）
		var query = PhysicsPointQueryParameters2D.new()
		query.position = p
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var hits = space_state.intersect_point(query)
		var in_a = false
		var in_b = false
		for hit in hits:
			if hit.collider == area_a:
				in_a = true
			elif hit.collider == area_b:
				in_b = true
		if in_a and in_b:
			return p
	# 保底：返回两个区域相交的随机点
	return get_any_intersection_point(area_a,area_b)

##获取一个Area2D的粗略全局包围盒（仅用于限定采样范围，允许不精确）
func get_area_bounds(area: Area2D) -> Rect2:
	var rect = Rect2()
	var first = true
	for child in area.get_children():
		if child is CollisionShape2D and child.shape:
			var shape_rect = get_shape_bounds(child)
			if first:
				rect = shape_rect
				first = false
			else:
				rect = rect.merge(shape_rect)
	return rect

## 获取单个碰撞形状的全局包围盒（支持旋转）
func get_shape_bounds(shape_node: CollisionShape2D) -> Rect2:
	var shape = shape_node.shape
	var xform = shape_node.global_transform
	if shape is RectangleShape2D:
		var half = shape.size * 0.5
		var points = [
			xform * Vector2(-half.x, -half.y),
			xform * Vector2( half.x, -half.y),
			xform * Vector2( half.x,  half.y),
			xform * Vector2(-half.x,  half.y)
		]
		return points_to_rect(points)
	elif shape is CircleShape2D:
		var center = xform.origin
		var r = shape.radius
		return Rect2(center - Vector2(r, r), Vector2(r*2, r*2))
	elif shape is ConvexPolygonShape2D or shape is ConcavePolygonShape2D:
		var points = PackedVector2Array()
		for p in shape.points:
			points.append(xform * p)
		return points_to_rect(points)
	return Rect2()

func points_to_rect(points: PackedVector2Array) -> Rect2:
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	for p in points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

## 返回两个 Area2D 重叠区域内的任意一点（Vector2），无重叠则返回 null
func get_any_intersection_point(area_a: Area2D, area_b: Area2D) -> Variant:
	var polys_a = _get_area_polygons(area_a)
	var polys_b = _get_area_polygons(area_b)
	for pa in polys_a:
		for pb in polys_b:
			var intersection = Geometry2D.intersect_polygons(pa, pb)
			if not intersection.is_empty():
				# 取第一个相交多边形的第一个顶点
				var first_poly = intersection[0]
				if first_poly.size() > 0:
					return first_poly[0]
	return null

## 辅助：获取 Area2D 所有碰撞形状的全局多边形（支持矩形、凸多边形、圆形）
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
				# 圆近似为正32边形
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
"""
