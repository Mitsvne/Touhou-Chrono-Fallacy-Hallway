class_name ItemCardUI
extends Control

signal card_selected(data: ItemCardData)

@export var icon_rect: TextureRect          # 道具图标
@export var bg_rect: TextureRect
@export var tooltip_panel: PanelContainer
@export var tooltip_rich_text: RichTextLabel
@export var tooltip_offset: Vector2 = Vector2(-100, -100)   # 相对卡片右下角的偏移

var card_data: ItemCardData = null
var hover_timer: SceneTreeTimer = null
var show_tween: Tween = null

# ==================== 初始化 ====================
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	# 初始透明并隐藏悬浮窗
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
	if icon_rect:
		icon_rect.texture = null
		icon_rect.modulate.a = 1.0
	if bg_rect:
		bg_rect.self_modulate = Color.WHITE

func _show_filled_slot(data: ItemCardData) -> void:
	if icon_rect:
		icon_rect.texture = data.icon
		icon_rect.modulate.a = 1.0
	if bg_rect:
		bg_rect.self_modulate = Color.WHITE



# ==================== 交互 ====================
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if card_data:
			card_selected.emit(card_data)
			_play_click_animate()

func _play_click_animate() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.05)

# ==================== 悬浮逻辑 ====================
func _on_mouse_entered() -> void:
	pivot_offset = size / 2
	create_tween().tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	# 终止旧动画，准备新的显示
	_kill_show_tween()
	if card_data == null or tooltip_panel == null: return
	# 启动延迟计时器
	hover_timer = get_tree().create_timer(0.6)
	await hover_timer.timeout
	# 二次确认（防止鼠标已移出）
	if hover_timer == null: return
	# 组装悬浮文本（使用 RichTextLabel 的 append_text 保证 BBCode 生效）
	tooltip_rich_text.clear()
	tooltip_rich_text.append_text("[color=#ffca3a]%s[/color]\n" % card_data.card_name)
	tooltip_rich_text.append_text("[i]%s[/i]\n\n" % card_data.description)
	# 固定位置：卡片右下角 + 偏移
	tooltip_panel.global_position = global_position + size + tooltip_offset
	tooltip_panel.show()
	# 渐显动画
	show_tween = create_tween()
	show_tween.tween_property(tooltip_panel, "modulate:a", 1.0, 0.15)

func _on_mouse_exited() -> void:
	# 恢复卡片大小
	create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	# 取消延迟
	hover_timer = null
	# 淡出悬浮窗
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
