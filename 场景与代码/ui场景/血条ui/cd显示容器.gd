extends HBoxContainer

var characters: Array[Node2D] = []
var fade_alpha: float = 0.3
var fade_duration: float = 0.2
var is_faded: bool = false
var tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	#获取所有人物
	characters.assign(get_tree().get_nodes_in_group("characters"))

func _process(_delta):
	# 遮挡角色时变透明
	var valid_characters: Array[Node2D] = []
	for c in characters:
		if is_instance_valid(c):
			valid_characters.append(c)
	characters = valid_characters
	# 没有角色时恢复不透明
	if characters.is_empty():
		if is_faded:
			fade_ui(1.0)
		return
	# 获取 UI 的屏幕矩形（已用 .abs() 修正负尺寸）
	var ui_rect: Rect2 = get_global_rect().abs()
	var should_fade := false
	for char_node in characters:
		# 玩家的世界坐标转屏幕坐标
		var player_screen_pos: Vector2 = char_node.get_global_transform_with_canvas().origin
		if ui_rect.has_point(player_screen_pos):
			should_fade = true
			break   # 只要有一个角色遮挡，就触发半透明
	if should_fade and not is_faded:
		fade_ui(fade_alpha)
	elif not should_fade and is_faded:
		fade_ui(1.0)

## 处理透明度渐变动画
func fade_ui(target_alpha: float) -> void:
	is_faded = (target_alpha < 1.0)
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, fade_duration)
