extends Control
@onready var v_box_container: VBoxContainer = $按钮深度/按钮盒竖状
@onready var button_1: Button = $按钮深度/按钮盒竖状/Button1
@onready var horizontal_blur: ColorRect = $水平模糊效果/水平模糊

# 获取所有按钮组成一个数组
func get_all_buttons(node: Node) -> Array:
	var buttons: Array = []
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
			child.modulate.a = 0.0
		if child.get_child_count() > 0:
			buttons += get_all_buttons(child)
	return buttons

# 排序2个按钮
func buttons_array_sorting(a: Button, b: Button) -> bool:
	if a.global_position.y == b.global_position.y:
		return a.global_position.x < b.global_position.x
	return a.global_position.y < b.global_position.y

# 按钮动画
func animate_buttons(buttons: Array, forward := true, delay_between_buttons := 0.16, move_offset := Vector2(-20, 0), scale_offset := Vector2.ZERO,animation_length:=0.5) -> void:
	# 反转按钮顺序（如果是反向动画）
	if !forward:
		buttons.reverse()
	# 设置所有按钮的初始状态
	for btn:Button in buttons:
		btn.modulate.a=0.0 if forward else 1.0
		btn.pivot_offset.x=btn.size.x/2.0
		btn.pivot_offset.y=btn.size.y/2.0
		btn.scale=scale_offset if forward else Vector2.ONE
	# 为每个按钮创建动画
	for i in buttons.size():
		var btn:Button = buttons[i]
		# 设置缓动函数：正向=EASE_OUT，反向=EASE_IN
		var tween_ease:int=Tween.EASE_OUT if forward else Tween.EASE_IN
		# 创建三个独立的补间动画
		var pos_tween:Tween=create_tween().set_trans(Tween.TRANS_BACK).set_ease(tween_ease)
		var modulate_tween:Tween=create_tween().set_trans(Tween.TRANS_BACK).set_ease(tween_ease)
		var scale_tween:Tween=create_tween().set_trans(Tween.TRANS_BACK).set_ease(tween_ease)
		# 设置动画目标值
		var target_pos:Vector2=btn.position - move_offset if forward else btn.position + move_offset
		var target_modulate:float=1.0 if forward else 0.0
		var target_scale:Vector2=Vector2.ONE if forward else scale_offset
		# 启动补间动画
		pos_tween.tween_property(btn, "position", target_pos, animation_length)
		modulate_tween.tween_property(btn, "modulate:a", target_modulate, animation_length)
		scale_tween.tween_property(btn, "scale", target_scale, animation_length)
		# 等待按钮间延迟
		await get_tree().create_timer(delay_between_buttons).timeout

func _ready() -> void:
	#出场动画
	var buttons: Array = get_all_buttons(self)
	await get_tree().create_timer(0.5).timeout
	await get_tree().process_frame
	buttons.sort_custom(buttons_array_sorting)
	animate_buttons(buttons.duplicate(), true,0.2,Vector2(0,0),Vector2(0,0),0.5)
	#鼠标控制焦点
	button_1.grab_focus()
	for button:Button in v_box_container.get_children():
		button.mouse_entered.connect(button.grab_focus)
#开始按钮
func _on_button_1_pressed() -> void:
	get_tree().change_scene_to_file("res://场景与代码/主程序/Main.tscn")
#设置按钮
signal _button_2_pressed
func _on_button_2_pressed() -> void:
	emit_signal("_button_2_pressed")
	horizontal_blur.start_blur_transition()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://场景与代码/ui场景与代码/设置页面/设置页面.tscn")
	
#退出按钮
func _on_button_3_pressed() -> void:
	get_tree().quit()
