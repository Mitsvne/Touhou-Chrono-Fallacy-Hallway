extends Control

# ===== 导出参数 =====
@export var item_spacing: float = 150.0               # 卡片间距
@export var animation_duration: float = 0.3           # 动画时长
@export var center_index: int = 0                     # 默认居中卡片索引
@export var center_position: Vector2 = Vector2(0, 80) # 居中卡片位置
# 缩放参数
@export var max_scale: float = 0.6                    # 居中卡片缩放
@export var min_scale: float = 0.4                    # 最远卡片缩放
# 透明度参数
@export var max_opacity: float = 1.0                  # 居中卡片不透明度
@export var min_opacity: float = 0.6                  # 最远卡片不透明度
# 图层参数
@export var z_index_range: int = 10                   # 居中卡片与最远卡片的z_index差值
@export var repeat_timer : Timer

# ===== 内部变量 =====
@export var card: Button                              # 卡片样张
var items: Array = []                                 # 存储所有卡片节点
var target_positions: Array = []                      # 每张卡片的目标位置
var current_center_index: int                         # 当前居中卡片索引
var tween: Tween                                      # 补间动画对象
var current_direction: int = 0                        # -1:左, 0:无, 1:右
var mouse_direction: int = 0
var mouse_held: bool = false                          # 石否在按鼠标

## ===== 初始化 =====
func _ready():
	current_center_index = center_index
	# 收集所有子控件作为卡片，并设置缩放中心
	for child in get_children():
		if child is Control:
			center_position=Vector2(self.size.x/2, self.size.y/2)-Vector2(child.size.x / 2, child.size.y / 2)
			child.pivot_offset = Vector2(child.size.x / 2, child.size.y / 2)
			items.append(child)
	calculate_target_positions()
	update_z_index()
	animate_to_target()
	card.grab_focus()

## ===== 输入处理 =====
## 按键切换
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_left"):
		scroll_left()
		key_start_repeat(-1)
	if Input.is_action_just_pressed(&"ui_right"):
		scroll_right()
		key_start_repeat(1)
	if Input.is_action_just_released(&"ui_left") or Input.is_action_just_released(&"ui_right"):
		current_direction = 0
		if not mouse_held:
			repeat_timer.stop()

func key_start_repeat(dir: int):
	current_direction = dir
	repeat_timer.start(0.2)

## 鼠标点击切换
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var click_pos = event.position
			var center_pos=center_position+Vector2(card.size.x / 2, card.size.y / 2)
			var left_boundary = center_pos.x - item_spacing / 2.0
			var right_boundary = center_pos.x + item_spacing / 2.0
			if click_pos.x < left_boundary:
				scroll_left()
				mouse_start_repeat(-1)
			elif click_pos.x > right_boundary:
				scroll_right()
				mouse_start_repeat(1)
		else:
			mouse_held = false
			mouse_direction = 0
			if current_direction == 0:
				repeat_timer.stop()

func mouse_start_repeat(dir: int):
	mouse_held = true
	mouse_direction = dir
	repeat_timer.start(0.2)

func _on_repeat_timer_timeout():
	if current_direction == -1:
		scroll_left()
	elif current_direction == 1:
		scroll_right()
	# 如果鼠标按住且没有键盘方向，则处理鼠标方向
	elif mouse_held:
		if mouse_direction == -1:
			scroll_left()
		elif mouse_direction == 1:
			scroll_right()


## ===== 核心逻辑 =====
## 计算所有卡片的目标位置（循环排列）
func calculate_target_positions():
	target_positions.clear()
	var n = items.size()
	var half = n / 2.0   # 每侧最大偏移量
	for i in range(n):
		# 计算循环偏移量
		var offset = wrap(i - current_center_index, -half, half)
		var pos = center_position + Vector2(offset * item_spacing, 0)
		target_positions.append(pos)

## 更新图层深度（基于循环距离）
func update_z_index():
	var n = items.size()
	var half = n / 2.0
	for i in range(n):
		var item = items[i]
		var offset = wrap(i - current_center_index, -half, half)
		var dist = abs(offset)
		var z = z_index_range - int(dist)
		item.z_index = max(z, 0)

## 执行补间动画（位置、缩放、透明度）
func animate_to_target():
	if tween and tween.is_valid():
		tween.kill()
	update_z_index()  # 动画开始前更新图层
	tween = create_tween()
	tween.set_parallel(true)
	var n = items.size()
	var half = n / 2.0
	var max_dist = floor(half)   # 最大整数距离
	for i in range(n):
		var item = items[i]
		if i==current_center_index:
			item.grab_focus()   #中间卡片获取焦点
		var target_pos = target_positions[i]
		# 计算循环距离
		var offset = wrap(i - current_center_index, -half, half)
		var dist = abs(offset)
		# 缩放插值
		var scale_factor = lerp(max_scale, min_scale, dist / max_dist)
		var target_scale = Vector2(scale_factor, scale_factor)
		# 透明度插值
		var opacity = lerp(max_opacity, min_opacity, dist / max_dist)
		var target_modulate = Color(1, 1, 1, opacity)
		# 添加补间属性
		tween.tween_property(item, "position", target_pos, animation_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(item, "scale", target_scale, animation_duration)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(item, "modulate", target_modulate, animation_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## 向左滚动（显示右侧卡片）
func scroll_left():
	current_center_index = wrap(current_center_index - 1, 0, items.size())
	calculate_target_positions()
	animate_to_target()

## 向右滚动（显示左侧卡片）
func scroll_right():
	current_center_index = wrap(current_center_index + 1, 0, items.size())
	calculate_target_positions()
	animate_to_target()
