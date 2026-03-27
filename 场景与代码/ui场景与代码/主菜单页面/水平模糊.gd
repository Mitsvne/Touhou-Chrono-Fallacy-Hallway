extends ColorRect

func _ready():
	# 设置鼠标穿透
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	#设置初始模糊值，可见
	set_visible(false)
	@warning_ignore("shadowed_variable_base_class")
	var material = self.material as ShaderMaterial
	if material:
		material.set_shader_parameter("strength", 0)
	
func start_blur_transition():
	# 1. 确保材质是 ShaderMaterial 类型
	@warning_ignore("shadowed_variable_base_class")
	var material = self.material as ShaderMaterial
	if not material:
		print("材质不是 ShaderMaterial 或未设置")
		return
	# 2. 使用 Tween 制作动画
	set_visible(true)
	var tween = create_tween()
	tween.tween_method(_set_blur, 0.0, 5.0, 0.5) # 在1.5秒内，从0变到4
	await tween.finished
	
	end_blur_transition()
	print("模糊转场完成！可以切换场景了")
	
func end_blur_transition():
	@warning_ignore("shadowed_variable_base_class")
	var material = self.material as ShaderMaterial
	if not material:
		print("材质不是 ShaderMaterial 或未设置")
		return
	set_visible(true)
	var tween = create_tween()
	tween.tween_method(_set_blur, 5.0, 0.0, 0.5)
	await tween.finished
	print("结束模糊")
	
	
# 一个辅助函数，由 Tween 每帧调用，用于设置模糊值
func _set_blur(value: float):
	@warning_ignore("shadowed_variable_base_class")
	var material = self.material as ShaderMaterial
	if material:
		material.set_shader_parameter("strength", value)
