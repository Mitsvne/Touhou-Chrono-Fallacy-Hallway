class_name ItemCardUI
extends Control

signal card_selected(data: ItemCardData)

@onready var name_label: Label = $"卡牌名字"
@onready var icon_rect: TextureRect = $"道具图标"
@onready var desc_label: Label = $"描述文本"

var card_data: ItemCardData = null

@export var hover_delay: float = 0.5
@export var text_offset_amount: float = 10.0   # 起始偏移（向下）

var hover_tween: Tween = null
# 保存文字标签的原始位置（动画终点）
var name_original_pos: Vector2
var desc_original_pos: Vector2

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# 记录初始位置（必须在节点树就绪之后）
	name_original_pos = name_label.position
	desc_original_pos = desc_label.position

	_hide_labels_immediate()

func init_card(data: ItemCardData) -> void:
	card_data = data
	if card_data == null:
		_show_empty_slot()
		return
	name_label.text = card_data.card_name
	icon_rect.texture = card_data.icon
	desc_label.text = card_data.description
	_hide_labels_immediate()

func _show_empty_slot() -> void:
	name_label.text = ""
	icon_rect.texture = null
	desc_label.text = ""
	_hide_labels_immediate()

# ==================== 悬停动画（position 上滑） ====================
func _on_mouse_entered() -> void:
	_kill_hover_tween()

	# 卡片本体放大动画（保持原样）
	pivot_offset = size / 2
	var tween_scale = create_tween().set_parallel(true)
	tween_scale.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_QUAD)
	tween_scale.tween_property(self, "modulate", Color(1.1, 1.1, 1.1), 0.1)

	# 重置文字到动画起始状态：向下偏移 + 全透明
	name_label.position = name_original_pos + Vector2(0, text_offset_amount)
	desc_label.position = desc_original_pos + Vector2(0, text_offset_amount)
	name_label.modulate.a = 0.0
	desc_label.modulate.a = 0.0

	# 延迟 + 动画
	hover_tween = create_tween()
	hover_tween.tween_interval(hover_delay)
	hover_tween.tween_callback(func(): pass)
	hover_tween.set_parallel(true)
	# 透明度 0 -> 1
	hover_tween.tween_property(name_label, "modulate:a", 1.0, 0.2)
	hover_tween.tween_property(desc_label, "modulate:a", 1.0, 0.2)
	# 位置从偏移恢复到原始位置（上滑效果）
	hover_tween.tween_property(name_label, "position", name_original_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(desc_label, "position", desc_original_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	_kill_hover_tween()
	_hide_labels_immediate()

	# 卡片恢复缩放
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _kill_hover_tween() -> void:
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
	hover_tween = null



func _hide_labels_immediate() -> void:
	# 立即隐藏：透明度归零，位置设回动画起点（向下偏移）
	name_label.modulate.a = 0.0
	desc_label.modulate.a = 0.0
	name_label.position = name_original_pos + Vector2(0, text_offset_amount)
	desc_label.position = desc_original_pos + Vector2(0, text_offset_amount)

# ==================== 点击动画保持不变 ====================
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if card_data != null:
			card_selected.emit(card_data)
			_play_click_animate()

func _play_click_animate() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.05)
