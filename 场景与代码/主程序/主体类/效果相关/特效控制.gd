extends Node
## 特效控制类 —— 残影、震屏、闪白
class_name Effect_Ctrler

# ============================================
# —— 内部数据类 ——
# ============================================

class ShakeParams:
	var intensity := Vector2.ZERO
	var frequency := 0.0
	var time := 0.0
	var one_shot_intensity := Vector2.ZERO

class ShadowData:
	var target: Node2D = null
	var color := Color(1, 1, 1, 0.5)
	var interval := 0.1
	var duration := 0.5
	var time_accum := 0.0

# ============================================
# —— 位掩码 & 状态 ——
# ============================================

enum EffectBit { SHADOW = 1, SHAKE = 2 }
var _active_mask: int = 0

var _shadow := ShadowData.new()
var _shake  := ShakeParams.new()
var _flash_layer: CanvasLayer = null


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var dt := delta * Engine.time_scale

	if _active_mask & EffectBit.SHADOW:
		_shadow.time_accum += dt
		while _shadow.time_accum >= _shadow.interval:
			_shadow.time_accum -= _shadow.interval
			_generate_shadow()

	if _active_mask & EffectBit.SHAKE:
		_update_camera_shake(dt)


# ============================================
# —— 残影 ——
# ============================================

## 代码/动画轨道通用入口：接受 Node2D 或 NodePath
func start_shadow(target, color: Color = Color(1, 1, 1, 0.5), interval: float = 0.1, duration: float = 0.5) -> void:
	var node: Node2D = null

	if target is NodePath:
		node = get_node_or_null(target) as Node2D
	elif target is Node2D:
		node = target

	if not is_instance_valid(node):
		push_error("Effect_Ctrler: 无法解析残影目标 -> ", target)
		return

	_shadow.target     = node
	_shadow.color      = color
	_shadow.interval   = interval
	_shadow.duration   = duration
	_shadow.time_accum = 0.0
	_set_effect_enabled(EffectBit.SHADOW, true)


func stop_shadow() -> void:
	_set_effect_enabled(EffectBit.SHADOW, false)


func _generate_shadow() -> void:
	var t := _shadow.target
	if not is_instance_valid(t) or not t.is_inside_tree():
		stop_shadow()
		return

	var shadow: Node2D
	if t is Sprite2D:
		shadow = Sprite2D.new()
	elif t is AnimatedSprite2D:
		shadow = AnimatedSprite2D.new()
	else:
		return

	_copy_visual_props(t, shadow)

	add_child(shadow)
	shadow.top_level = true
	shadow.global_transform = t.global_transform
	shadow.modulate = _shadow.color
	shadow.z_index = t.z_index - 1

	var tween := shadow.create_tween()
	tween.tween_property(shadow, "modulate:a", 0.0, _shadow.duration)
	tween.finished.connect(shadow.queue_free)


# ============================================
# —— 震屏 ——
# ============================================

func shake_once(intensity: Vector2, duration: float = 0.2) -> void:
	_set_effect_enabled(EffectBit.SHAKE, true)
	_shake.one_shot_intensity = intensity

	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_shake, "one_shot_intensity", Vector2.ZERO, duration)
	tween.finished.connect(func():
		if _shake.intensity.length_squared() < 0.01:
			_set_effect_enabled(EffectBit.SHAKE, false)
	)


func start_shake(intensity: Vector2, frequency: float = 30.0) -> void:
	_shake.intensity = intensity
	_shake.frequency = frequency
	_set_effect_enabled(EffectBit.SHAKE, true)


func stop_shake() -> void:
	_shake.intensity = Vector2.ZERO
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.offset = Vector2.ZERO
	_set_effect_enabled(EffectBit.SHAKE, false)


func _update_camera_shake(dt: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if not cam:
		return

	_shake.time += dt * _shake.frequency
	var noise := Vector2(
		sin(_shake.time) * _shake.intensity.x,
		cos(_shake.time * 1.3) * _shake.intensity.y
	)
	var rand_offset := Vector2(
		randf_range(-_shake.one_shot_intensity.x, _shake.one_shot_intensity.x),
		randf_range(-_shake.one_shot_intensity.y, _shake.one_shot_intensity.y)
	)
	cam.offset = noise + rand_offset


# ============================================
# —— 闪白 ——
# ============================================

func flash(duration: float, color: Color = Color.WHITE) -> void:
	var layer := _get_or_create_flash_layer()
	var rect := ColorRect.new()
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.set_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)

	var tween := rect.create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration).set_ease(Tween.EASE_OUT)
	tween.finished.connect(rect.queue_free)


# ============================================
# —— 内部工具 ——
# ============================================

func _copy_visual_props(src: Node2D, dst: Node2D) -> void:
	# Node2D 公共属性
	dst.centered = src.centered
	dst.offset   = src.offset
	dst.flip_h   = src.flip_h
	dst.flip_v   = src.flip_v

	if src is Sprite2D and dst is Sprite2D:
		dst.texture        = src.texture
		dst.hframes        = src.hframes
		dst.vframes        = src.vframes
		dst.frame          = src.frame
		dst.region_enabled = src.region_enabled
		dst.region_rect    = src.region_rect
	elif src is AnimatedSprite2D and dst is AnimatedSprite2D:
		dst.sprite_frames  = src.sprite_frames
		dst.animation      = src.animation
		dst.frame          = src.frame


func _set_effect_enabled(bit: int, enabled: bool) -> void:
	if enabled:
		_active_mask |= bit
	else:
		_active_mask &= ~bit
	set_physics_process(_active_mask != 0)


func _get_or_create_flash_layer() -> CanvasLayer:
	if not is_instance_valid(_flash_layer):
		_flash_layer = CanvasLayer.new()
		_flash_layer.layer = 128
		add_child(_flash_layer)
	return _flash_layer
