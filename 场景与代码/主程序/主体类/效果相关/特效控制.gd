extends Node
## 特效控制类：产生各种特效效果
class_name Effect_Ctrler

func _ready() -> void:
	set_physics_process(false)

## ---------- 持续效果数据结构 ---------- #
# 存储当前激活的效果数据
var active_effects: Dictionary = {}
# 用于暂停/恢复持续震动时暂存参数
var _saved_shake_params: Dictionary = {}


## ---------- _process 统一更新 ---------- #
func _physics_process(delta: float) -> void:
	var cam = get_active_camera()
	var scaled_delta = delta * Engine.time_scale
	## ----- 持续残影 -----
	if active_effects.has("shadow"):
		var data = active_effects["shadow"]
		data.time_accum += scaled_delta
		while data.time_accum >= data.interval:
			data.time_accum -= data.interval
			_generate_shadow(data)
	##----- 持续震动 -----
	if active_effects.has("shake") and cam:
		var data = active_effects["shake"]
		data.time_accum += scaled_delta
		var offset = Vector2(
			sin(data.time_accum * data.frequency) * data.intensity_x,
			cos(data.time_accum * data.frequency * 1.3) * data.intensity_y
		)
		cam.offset = offset


## ---------- 残影效果（持续生成） ---------- #
func start_shadow(target: Variant, color: Color = Color(1, 1, 1, 0.5), interval: float = 0.1, duration: float = 0.5):
	stop_shadow(false)
	# 解析 target
	var target_node: Node2D = null
	var target_path: NodePath = NodePath()
	if target is NodePath:
		target_path = target
	elif target is Node2D:
		target_node = target
	else:
		push_error("start_shadow: target must be NodePath or Node2D")
		return
	active_effects["shadow"] = {
		"target_node": target_node,
		"target_path": target_path,
		"color": color,
		"interval": interval,
		"duration": duration,
		"time_accum": 0.0
	}
	set_physics_process(true)

## 停止生成残影
func stop_shadow(clear_existing: bool = false):
	if active_effects.erase("shadow"):
		if clear_existing:
			clear_all_shadows()
	if active_effects.is_empty():
		set_physics_process(false)

## 清除所有残影
func clear_all_shadows():
	for child in get_children():
		if child is Node2D and child.is_in_group("shadow"):
			child.queue_free()

## 生成一个残影实例
func _generate_shadow(data: Dictionary):
	var t: Node2D = null
	if data.target_path != NodePath():
		t = get_node(data.target_path) as Node2D
		if not t:
			push_error("Shadow target node not found at path: ", data.target_path)
			stop_shadow(false)
			return
	else:
		t = data.target_node
		if not is_instance_valid(t):
			stop_shadow(false)
			return
	var shadow = _create_shadow_instance(t, data.color, data.duration)
	if shadow:
		add_child(shadow)

## 创建一个残影
func _create_shadow_instance(target: Node2D, color: Color, duration: float) -> Node2D:
	var shadow: Node2D
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
		if target.has_method("get_texture"):
			var sprite = Sprite2D.new()
			sprite.texture = target.get_texture()
			shadow = sprite
		else:
			return null
	shadow.add_to_group("shadow")
	shadow.global_position = target.global_position
	shadow.global_rotation = target.global_rotation
	shadow.scale = target.scale
	shadow.modulate = color
	shadow.z_index = -1
	if target.material:
		shadow.material = target.material.duplicate()
	var tween = shadow.create_tween()
	tween.tween_property(shadow, "modulate:a", 0.0, duration)
	tween.finished.connect(shadow.queue_free)
	return shadow


# ---------- 震动效果 ---------- #
## 获取活动的相机
func get_active_camera() -> Camera2D:
	var viewport = get_viewport()
	if viewport:
		return viewport.get_camera_2d()
	return null

## 单次震动
func shake_once(intensity_x: float, intensity_y: float, duration: float = 0.2):
	var cam = get_active_camera()
	if not cam:
		return
	var was_shaking = active_effects.has("shake")
	if was_shaking:
		# 保存原持续震动参数
		var data = active_effects["shake"]
		_saved_shake_params = {
			"intensity_x": data.intensity_x,
			"intensity_y": data.intensity_y,
			"frequency": data.frequency
		}
		stop_shake()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var steps = int(duration * 60)
	for i in range(steps):
		var progress = float(i) / steps
		var current_intensity = Vector2(intensity_x, intensity_y) * (1.0 - progress)
		var offset = Vector2(
			randf_range(-current_intensity.x, current_intensity.x),
			randf_range(-current_intensity.y, current_intensity.y)
		)
		tween.tween_callback(_apply_offset.bind(cam, offset)).set_delay(duration / steps)
	tween.tween_callback(_apply_offset.bind(cam, Vector2.ZERO))
	if was_shaking:
		tween.tween_callback(func():
			start_shake(
				_saved_shake_params.intensity_x,
				_saved_shake_params.intensity_y,
				_saved_shake_params.frequency
			)
		)

## 应用相机偏移
func _apply_offset(cam: Camera2D, offset: Vector2):
	if is_instance_valid(cam):
		cam.offset = offset

## 开始持续震动
func start_shake(intensity_x: float, intensity_y: float, frequency: float = 30.0):
	stop_shake()
	var cam = get_active_camera()
	if not cam:
		return
	active_effects["shake"] = {
		"intensity_x": intensity_x,
		"intensity_y": intensity_y,
		"frequency": frequency,
		"time_accum": 0.0
	}
	set_physics_process(true)

## 停止持续震动
func stop_shake():
	if active_effects.erase("shake"):
		var cam = get_active_camera()
		if cam:
			cam.offset = Vector2.ZERO
	if active_effects.is_empty():
		set_physics_process(false)

## ---------- 闪光效果 ---------- #
var _flash_layer: CanvasLayer = null
func flash(duration: float, color: Color = Color.WHITE, fade_out: bool = true):
	var canvas_layer = _get_or_create_flash_layer()
	# 创建全屏 ColorRect
	var rect = ColorRect.new()
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 不阻挡点击
	rect.anchor_left = 0.0
	rect.anchor_right = 1.0
	rect.anchor_top = 0.0
	rect.anchor_bottom = 1.0
	rect.offset_left = 0.0
	rect.offset_right = 0.0
	rect.offset_top = 0.0
	rect.offset_bottom = 0.0
	canvas_layer.add_child(rect)
	if fade_out:
		rect.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_property(rect, "modulate:a", 0.0, duration)
		tween.finished.connect(rect.queue_free)
	else:
		rect.modulate.a = 1.0
		get_tree().create_timer(duration).timeout.connect(rect.queue_free)

## 获取或创建用于闪光效果的 CanvasLayer（始终置于最上层）
func _get_or_create_flash_layer() -> CanvasLayer:
	if _flash_layer and is_instance_valid(_flash_layer):
		return _flash_layer
	_flash_layer = CanvasLayer.new()
	_flash_layer.layer = 128  # 较高的层级，确保在 UI 和游戏内容之上
	_flash_layer.name = "FlashLayer"
	add_child(_flash_layer)
	return _flash_layer
	
## ---------- 纹理透明渐变（保留原有） ---------- #
func fade_to_alpha(node: CanvasItem, target_alpha: float, duration: float = 1.0, on_completed: Callable = Callable()):
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", target_alpha, duration)
	if on_completed:
		tween.finished.connect(on_completed)
