extends Control
class_name SkillSlotUI

signal slot_clicked(slot: SkillSlotUI)

@export var icon_rect: TextureRect
@export var select_border: Control
@export var tooltip_panel: PanelContainer
@export var tooltip_rich_text: RichTextLabel
@export var tooltip_offset: Vector2 = Vector2(-20, -20)

var skill_data: SkillData = null
var is_equipped: bool = false
var hover_timer: SceneTreeTimer = null
var show_tween: Tween = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	# 初始透明且隐藏
	if tooltip_panel:
		tooltip_panel.modulate.a = 0.0
		tooltip_panel.hide()

func update_slot(data: SkillData, currently_equipped_skill: SkillData) -> void:
	skill_data = data
	if skill_data == null:
		hide()
		return
	show()
	if icon_rect: icon_rect.texture = skill_data.icon
	is_equipped = (skill_data == currently_equipped_skill)
	if select_border: select_border.visible = is_equipped
	if icon_rect: icon_rect.modulate = Color.WHITE if is_equipped else Color(0.7, 0.7, 0.7)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if skill_data:
			slot_clicked.emit(self)

# ==================== 效果 ====================

func _on_mouse_entered() -> void:
	# 放大反馈
	pivot_offset = size / 2
	create_tween().tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	# 立刻取消之前的显示动画（如果有）
	_kill_show_tween()
	if skill_data == null or tooltip_panel == null: return
	# 启动延迟计时器
	hover_timer = get_tree().create_timer(0.4)
	await hover_timer.timeout
	if hover_timer == null: return   # 已被鼠标移出取消
	# 组装文本（使用 append_text 保证 BBCode 正确渲染）
	tooltip_rich_text.clear()
	tooltip_rich_text.append_text("[color=#ffca3a]%s[/color]\n" % skill_data.skill_name)
	tooltip_rich_text.append_text("[color=#8ac926]消耗: %d[/color]\n" % skill_data.mp_cost)
	tooltip_rich_text.append_text("[color=#ff595e]CD: %.1fs[/color]\n" % skill_data.cd)
	tooltip_rich_text.append_text("[i]%s[/i]" % skill_data.description)
	# 固定位置：卡槽的右下角 + 预设偏移
	tooltip_panel.global_position = global_position + size + tooltip_offset
	tooltip_panel.show()
	# 渐显动画
	show_tween = create_tween()
	show_tween.tween_property(tooltip_panel, "modulate:a", 1.0, 0.15)

func _on_mouse_exited() -> void:
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
