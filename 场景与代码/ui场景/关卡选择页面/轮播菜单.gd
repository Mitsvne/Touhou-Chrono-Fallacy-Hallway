extends Control

@export var item_spacing: float = 400.0 # 卡片间距
@export var animation_duration: float = 0.3 # 动画时长
@export var center_index: int = 1 # 默认居中的卡片索引

var items: Array = []
var target_positions: Array = []
var current_center_index: int
var tween: Tween

func _ready():
	current_center_index = center_index
	# 收集所有子节点作为轮播项
	for child in get_children():
		if child is Control:
			items.append(child)
	calculate_target_positions()
	animate_to_target()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"move_left_1p"):
		scroll_left()
	if Input.is_action_just_pressed(&"move_right_1p"):
		scroll_right()

# 计算所有卡片的目标位置 (假设是水平轮播)
func calculate_target_positions():
	target_positions.clear()
	for i in range(items.size()):
		var x_offset = (i - current_center_index) * item_spacing
		target_positions.append(Vector2(x_offset+175, 80))

# 用 Tween 将所有卡片平滑移动到目标位置
func animate_to_target():
	# 如果已有动画在运行，先停止
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	for i in range(items.size()):
		var item = items[i]
		var target_pos = target_positions[i]
		var target_scale = Vector2(0.5, 0.5) if i == current_center_index else Vector2(0.5, 0.5)
		tween.tween_property(item, "position", target_pos, animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(item, "scale", target_scale, animation_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# 向左滚动
func scroll_left():
	current_center_index = wrap(current_center_index - 1, 0, items.size())
	calculate_target_positions()
	animate_to_target()

# 向右滚动
func scroll_right():
	current_center_index = wrap(current_center_index + 1, 0, items.size())
	calculate_target_positions()
	animate_to_target()
