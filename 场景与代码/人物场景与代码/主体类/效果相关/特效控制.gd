extends Node
class_name Effect_Ctrler

var _active_timer: Timer = null   # 保存当前活动的定时器
func _ready() -> void:
	print("Effect_Ctrler初始化完成")
## 开始产生残影效果
func start_shadow(target: Variant, color: Color = Color(1, 1, 1, 0.5), interval: float = 0.1, duration: float = 0.5):
	# 停止已有的残影效果
	if _active_timer and is_instance_valid(_active_timer):
		stop_current_shadow(_active_timer, false)
	# 处理 target 参数
	var target_node: Node2D = null
	var target_path: NodePath = NodePath()
	if target is NodePath:
		target_path = target
	elif target is Node2D:
		target_node = target
	else:
		push_error("start_shadow: target must be NodePath or Node2D")
		return null
	# 创建新定时器
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = interval
	timer.one_shot = false
	timer.timeout.connect(func():
		var t: Node2D = null
		if target_path != NodePath():
			t = get_node(target_path) as Node2D
			if not t:
				push_error("start_shadow: target node not found at path: ", target_path)
				return
		else:
			t = target_node
			if not is_instance_valid(t):
				# 节点已被销毁，停止残影生成
				stop_current_shadow(timer, true)
				return
		var shadow = _create_shadow_instance(t, color, duration)
		if shadow:
			add_child(shadow)
	)
	timer.start()
	_active_timer = timer
	return timer

## 停止生成残影
func stop_shadow(clear_existing: bool = false):
	if _active_timer and is_instance_valid(_active_timer):
		stop_current_shadow(_active_timer, clear_existing)

## 停止当前正在运行的残影效果
func stop_current_shadow(timer: Timer, clear_existing: bool = false) -> void:
	if not is_instance_valid(timer):
		return
	timer.stop()
	timer.queue_free()
	if clear_existing:
		clear_all_shadows()
	# 如果停止的是当前活动的定时器，清空引用
	if _active_timer == timer:
		_active_timer = null

## 清除所有残影
func clear_all_shadows() -> void:
	for child in get_children():
		if child is Node2D and child.is_in_group("shadow"):
			child.queue_free()

## 内部方法：创建单个残影实例
func _create_shadow_instance(target: Node2D, color: Color, duration: float) -> Node2D:
	var shadow: Node2D
	#根据类型创造目标
	if target is Sprite2D:
		var sprite = Sprite2D.new()
		sprite.texture = target.texture
		sprite.centered = target.centered
		sprite.offset = target.offset
		sprite.hframes = target.hframes
		sprite.vframes = target.vframes
		sprite.frame = target.frame
		sprite.region_enabled = target.region_enabled
		sprite.region_rect = target.region_rect
		sprite.flip_h = target.flip_h
		sprite.flip_v = target.flip_v
		shadow = sprite
	elif target is AnimatedSprite2D:
		var animated = AnimatedSprite2D.new()
		animated.sprite_frames = target.sprite_frames
		animated.animation = target.animation
		animated.frame = target.frame
		animated.offset = target.offset
		animated.centered = target.centered
		animated.flip_h = target.flip_h
		animated.flip_v = target.flip_v
		animated.stop()
		shadow = animated
	else:
		# 对于其他类型，尝试获取纹理
		if target.has_method("get_texture"):
			var sprite = Sprite2D.new()
			sprite.texture = target.get_texture()
			shadow = sprite
		else:
			return null
	# 通用设置（位置、旋转、缩放、颜色、材质等）
	shadow.add_to_group("shadow")
	shadow.global_position = target.global_position
	shadow.global_rotation = target.global_rotation
	shadow.scale = target.scale
	shadow.modulate = color
	shadow.z_index = -1
	if target.material:
		shadow.material = target.material.duplicate()
	# 淡出动画
	var tween = shadow.create_tween()
	tween.tween_property(shadow, "modulate:a", 0.0, duration)
	tween.finished.connect(shadow.queue_free)
	return shadow
