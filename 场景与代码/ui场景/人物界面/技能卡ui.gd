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

# 【优化】引入专门的变量管理缩放动画
var show_tween: Tween = null
var scale_tween: Tween = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
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
	# 【优化】安全杀死上一次的缩放动画，防止鬼畜摩擦
	if scale_tween and scale_tween.is_valid(): scale_tween.kill()
	pivot_offset = size / 2
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	
	_kill_show_tween()
	if skill_data == null or tooltip_panel == null: return
	
	hover_timer = get_tree().create_timer(0.4)
	await hover_timer.timeout
	if hover_timer == null: return 
	
	# 组装文本
	tooltip_rich_text.clear()
	tooltip_rich_text.append_text("[color=#ffca3a]%s[/color]\n" % skill_data.skill_name)
	tooltip_rich_text.append_text("[color=#8ac926]消耗: %d[/color]\n" % skill_data.mp_cost)
	tooltip_rich_text.append_text("[color=#ff595e]CD: %.1fs[/color]\n" % skill_data.cd)
	tooltip_rich_text.append_text("[i]%s[/i]" % skill_data.description)
	
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
	# 【优化】安全杀死缩放动画并还原
	if scale_tween and scale_tween.is_valid(): scale_tween.kill()
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
