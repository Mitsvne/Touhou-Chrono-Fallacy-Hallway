extends Bullet

@export var audio: AudioStream
@onready var sprite: Sprite2D = $图形

func init() -> void:
	AudioManager.play_sfx(audio,-10)
	material_copy()
	bullet_ctrler.start_move_forward(600,-100)
	await get_tree().create_timer(3, false).timeout
	queue_free()

func hit() -> void:
	bullet_ctrler.stop_move()
	animate_fill_from(sprite.material.get_shader_parameter("add"), 0.3)
	animate_fill_to(sprite.material.get_shader_parameter("sub"), 0.3)
	await get_tree().create_timer(0.29).timeout
	queue_free()

## 着色器资源复制
func material_copy():
	sprite.material = sprite.material.duplicate()
	var mat = sprite.material as ShaderMaterial
	# 处理 add 纹理
	var add_original = mat.get_shader_parameter("add")
	if add_original is GradientTexture2D:
		var add_tex = add_original.duplicate()
		mat.set_shader_parameter("add", add_tex)
	# 处理 sub 纹理
	var sub_original = mat.get_shader_parameter("sub")
	if sub_original is GradientTexture2D:
		var sub_tex = sub_original.duplicate()
		mat.set_shader_parameter("sub", sub_tex)
	#print("材质ID：", sprite.material.get_instance_id())
	#print("add纹理ID：", sprite.material.get_shader_parameter("add").get_instance_id())
	#print("sub纹理ID：", sprite.material.get_shader_parameter("sub").get_instance_id())

## 着色器动画1
func animate_fill_from(tex: GradientTexture2D, duration: float = 1.5) -> Tween:
	var tween = create_tween()
	tween.tween_method(
		func(y: float):
			tex.fill_from = Vector2(1.0, y)
			tex.emit_changed()
			, 0.0, 1.0, duration
		)
	return tween

## 着色器动画2
func animate_fill_to(tex: GradientTexture2D, duration: float = 1.5) -> Tween:
	var tween = create_tween()
	tween.tween_method(
		func(y: float):
			tex.fill_to = Vector2(1.0, y)
			tex.emit_changed()
			, 0.0, 1.0, duration
	)
	return tween
