class_name ItemCardUI
extends Control

signal card_selected(data: ItemCardData)

@export var icon_rect: TextureRect          # 道具图标
@export var bg_rect: TextureRect
@export var tooltip_panel: PanelContainer
@export var tooltip_rich_text: RichTextLabel
@export var tooltip_offset: Vector2 = Vector2(-20, -150)   # 相对卡片右下角的偏移

var card_data: ItemCardData = null
var hover_timer: SceneTreeTimer = null
var show_tween: Tween = null
# 【新增】引入统一的全局缩放动画控制器
var scale_tween: Tween = null

# ==================== 初始化 ====================
func _ready() -> void:
	# 初始连接（注意：具体的 mouse_filter 我们在 init 里面动态改）
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if tooltip_panel:
		tooltip_panel.modulate.a = 0.0
		tooltip_panel.hide()

func init_card(data: ItemCardData) -> void:
	card_data = data
	if card_data == null:
		_show_empty_slot()
	else:
		_show_filled_slot(card_data)

func _show_empty_slot() -> void:
	# 【核心优化】如果卡片是空的，直接无视鼠标！
	# 这样它绝对不会触发任何 hover 放大、点击或弹窗逻辑，省心省力
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if icon_rect:
		icon_rect.texture = null
	if bg_rect:
		bg_rect.self_modulate = Color(1, 1, 1, 1.0) # 空格子可以微微变透明

func _show_filled_slot(data: ItemCardData) -> void:
	# 【核心优化】只有有道具时，才拦截鼠标吞噬事件
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if icon_rect:
		icon_rect.texture = data.icon
		icon_rect.modulate.a = 1.0
	if bg_rect:
		bg_rect.self_modulate = Color.WHITE

# ==================== 交互 ====================
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 既然前面靠 mouse_filter 过滤了，这里连 if card_data 的判断都可以省了
		card_selected.emit(card_data)
		_play_click_animate()

func _play_click_animate() -> void:
	# 【核心优化】点击时，先掐死之前的悬浮/缩放动画，统一归档
	_kill_scale_tween()
	
	scale_tween = create_tween()
	# 压扁，再弹回 hover 的 1.05 状态
	scale_tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	scale_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.05)

# ==================== 悬浮逻辑 ====================
func _on_mouse_entered() -> void:
	# 【核心优化】使用统一的缩放动画管理
	_kill_scale_tween()
	
	pivot_offset = size / 2
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	
	_kill_show_tween()
	if tooltip_panel == null: return
	
	hover_timer = get_tree().create_timer(0.6)
	await hover_timer.timeout
	if hover_timer == null: return
	
	# 组装悬浮文本
	tooltip_rich_text.clear()
	tooltip_rich_text.append_text("[color=#ffca3a]%s[/color]\n" % card_data.card_name)
	tooltip_rich_text.append_text("[i]%s[/i]\n\n" % card_data.description)
	
	# 【优化】智能防出界算法：计算右下角坐标
	var target_pos = global_position + size + tooltip_offset
	# 如果超出了屏幕宽度，自动将弹窗往左边弹
	var screen_width = get_viewport_rect().size.x
	if target_pos.x + tooltip_panel.size.x > screen_width:
		target_pos.x = global_position.x - tooltip_panel.size.x - tooltip_offset.x
		
	tooltip_panel.global_position = target_pos
	tooltip_panel.show()
	
	show_tween = create_tween()
	show_tween.tween_property(tooltip_panel, "modulate:a", 1.0, 0.15)

func _on_mouse_exited() -> void:
	# 【核心优化】移出时同样清理动画，确保回归 1.0
	_kill_scale_tween()
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	hover_timer = null
	if tooltip_panel and tooltip_panel.visible:
		_kill_show_tween()
		show_tween = create_tween()
		show_tween.tween_property(tooltip_panel, "modulate:a", 0.0, 0.1)
		show_tween.tween_callback(_hide_panel)

func _hide_panel() -> void:
	tooltip_panel.hide()

func _kill_show_tween() -> void:
	if show_tween and show_tween.is_valid():
		show_tween.kill()
	show_tween = null

# 【新增】清理缩放动画的辅助函数
func _kill_scale_tween() -> void:
	if scale_tween and scale_tween.is_valid():
		scale_tween.kill()
	scale_tween = null
