extends Node
## 特效控制类：产生各种特效效果
class_name Effect_Ctrler

# --- 内部类：解决 Tween 无法操作 Dictionary 的问题 ---
class ShakeParams:
	var intensity := Vector2.ZERO
	var frequency := 0.0
	var time := 0.0
	var one_shot_intensity := Vector2.ZERO

enum EffectBit { SHADOW = 1, SHAKE = 2 }
var _active_mask: int = 0

# --- 数据存储 ---
var _shadow_data: Dictionary = {}
var _shake_data = ShakeParams.new()
var _flash_layer: CanvasLayer

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	var scaled_delta = delta * Engine.time_scale
	
	if _active_mask & EffectBit.SHADOW:
		_shadow_data.time_accum += scaled_delta
		while _shadow_data.time_accum >= _shadow_data.interval:
			_shadow_data.time_accum -= _shadow_data.interval
			_generate_shadow()

	if _active_mask & EffectBit.SHAKE:
		_update_camera_shake(scaled_delta)

# --- 残影效果 (支持 NodePath) ---

## 启动持续残影
## @param target: 可以是 Node2D 实例，也可以是 NodePath 路径
func start_shadow(target: Variant, color: Color = Color(1, 1, 1, 0.5), interval: float = 0.1, duration: float = 0.5):
	var target_node: Node2D = null
	
	# 路径解析逻辑
	if target is NodePath:
		target_node = get_node_or_null(target) as Node2D
	elif target is Node2D:
		target_node = target
		
	if not is_instance_valid(target_node):
		push_error("Effect_Ctrler: 无法解析残影目标节点 -> ", target)
		return

	_shadow_data = {
		"target": target_node,
		"color": color,
		"interval": interval,
		"duration": duration,
		"time_accum": 0.0
	}
	_set_effect_enabled(EffectBit.SHADOW, true)

func stop_shadow():
	_set_effect_enabled(EffectBit.SHADOW, false)

func _generate_shadow():
	var t = _shadow_data.target
	if not is_instance_valid(t) or not t.is_inside_tree():
		stop_shadow()
		return
		
	var shadow: Node2D
	if t is Sprite2D:
		shadow = Sprite2D.new()
		_copy_sprite_props(t, shadow)
	elif t is AnimatedSprite2D:
		shadow = AnimatedSprite2D.new()
		_copy_animated_sprite_props(t, shadow)
	else:
		return

	# 设置残影基础属性
	add_child(shadow)
	shadow.top_level = true 
	shadow.global_transform = t.global_transform
	shadow.modulate = _shadow_data.color
	shadow.z_index = t.z_index - 1
	
	var tween = shadow.create_tween()
	tween.tween_property(shadow, "modulate:a", 0.0, _shadow_data.duration)
	tween.finished.connect(shadow.queue_free)

# --- 震动效果 (使用 ShakeParams 类) ---

func shake_once(intensity: Vector2, duration: float = 0.2):
	_set_effect_enabled(EffectBit.SHAKE, true)
	_shake_data.one_shot_intensity = intensity
	
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# 此时 _shake_data 是 Object，不再报错
	tween.tween_property(_shake_data, "one_shot_intensity", Vector2.ZERO, duration)
	
	tween.finished.connect(func(): 
		if _shake_data.intensity.length_squared() < 0.01:
			_set_effect_enabled(EffectBit.SHAKE, false)
	)

func start_shake(intensity: Vector2, frequency: float = 30.0):
	_shake_data.intensity = intensity
	_shake_data.frequency = frequency
	_set_effect_enabled(EffectBit.SHAKE, true)

func stop_shake():
	_shake_data.intensity = Vector2.ZERO
	var cam = get_viewport().get_camera_2d()
	if cam: cam.offset = Vector2.ZERO
	_set_effect_enabled(EffectBit.SHAKE, false)


# --- 闪光效果优化 ---

func flash(duration: float, color: Color = Color.WHITE):
	var layer = _get_or_create_flash_layer()
	var rect = ColorRect.new()
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	
	var tween = rect.create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration).set_ease(Tween.EASE_OUT)
	tween.finished.connect(rect.queue_free)


# --- 内部辅助函数 ---

func _update_camera_shake(delta: float):
	var cam = get_viewport().get_camera_2d()
	if not cam: return
	
	_shake_data.time += delta * _shake_data.frequency
	var noise = Vector2(
		sin(_shake_data.time) * _shake_data.intensity.x,
		cos(_shake_data.time * 1.3) * _shake_data.intensity.y
	)
	
	# 叠加一过性震动幅度
	var rand_offset = Vector2(
		randf_range(-_shake_data.one_shot_intensity.x, _shake_data.one_shot_intensity.x),
		randf_range(-_shake_data.one_shot_intensity.y, _shake_data.one_shot_intensity.y)
	)
	cam.offset = noise + rand_offset

func _copy_sprite_props(src: Sprite2D, dst: Sprite2D):
	dst.texture = src.texture
	dst.hframes = src.hframes
	dst.vframes = src.vframes
	dst.frame = src.frame
	dst.region_enabled = src.region_enabled
	dst.region_rect = src.region_rect
	dst.centered = src.centered
	dst.offset = src.offset
	dst.flip_h = src.flip_h
	dst.flip_v = src.flip_v

func _copy_animated_sprite_props(src: AnimatedSprite2D, dst: AnimatedSprite2D):
	dst.sprite_frames = src.sprite_frames
	dst.animation = src.animation
	dst.frame = src.frame
	dst.centered = src.centered
	dst.offset = src.offset
	dst.flip_h = src.flip_h
	dst.flip_v = src.flip_v

func _set_effect_enabled(bit: int, enabled: bool):
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
