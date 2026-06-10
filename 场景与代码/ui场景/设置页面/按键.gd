extends Control

# 当前是否正在等待玩家按下新按键
var is_listening := false
var current_action_rebind := ""
var current_set_button: Button = null
var current_bind_slot := 0  # 0 = 主键, 1 = 副键

# --- 主键按钮 ---
@export var set_btn_move_up :Button
@export var reset_btn_move_up :Button
@export var set_btn_move_up_2 :Button
@export var reset_btn_move_up_2 :Button

@export var set_btn_move_down :Button
@export var reset_btn_move_down :Button
@export var set_btn_move_down_2 :Button
@export var reset_btn_move_down_2 :Button

@export var set_btn_move_left :Button
@export var reset_btn_move_left :Button
@export var set_btn_move_left_2 :Button
@export var reset_btn_move_left_2 :Button

@export var set_btn_move_right :Button
@export var reset_btn_move_right :Button
@export var set_btn_move_right_2 :Button
@export var reset_btn_move_right_2 :Button

@export var set_btn_attack :Button
@export var reset_btn_attack :Button
@export var set_btn_attack_2 :Button
@export var reset_btn_attack_2 :Button

@export var set_btn_dash :Button
@export var reset_btn_dash :Button
@export var set_btn_dash_2 :Button
@export var reset_btn_dash_2 :Button

@export var set_btn_defense :Button
@export var reset_btn_defense :Button
@export var set_btn_defense_2 :Button
@export var reset_btn_defense_2 :Button

@export var set_btn_skill :Button
@export var reset_btn_skill :Button
@export var set_btn_skill_2 :Button
@export var reset_btn_skill_2 :Button

@export var set_btn_ultimate :Button
@export var reset_btn_ultimate :Button
@export var set_btn_ultimate_2 :Button
@export var reset_btn_ultimate_2 :Button

@export var set_btn_assist :Button
@export var reset_btn_assist :Button
@export var set_btn_assist_2 :Button
@export var reset_btn_assist_2 :Button


func _ready() -> void:
	_connect_action("move_up",    set_btn_move_up,    reset_btn_move_up,    set_btn_move_up_2,    reset_btn_move_up_2)
	_connect_action("move_down",  set_btn_move_down,  reset_btn_move_down,  set_btn_move_down_2,  reset_btn_move_down_2)
	_connect_action("move_left",  set_btn_move_left,  reset_btn_move_left,  set_btn_move_left_2,  reset_btn_move_left_2)
	_connect_action("move_right", set_btn_move_right, reset_btn_move_right, set_btn_move_right_2, reset_btn_move_right_2)
	_connect_action("attack",     set_btn_attack,     reset_btn_attack,     set_btn_attack_2,     reset_btn_attack_2)
	_connect_action("dash",       set_btn_dash,       reset_btn_dash,       set_btn_dash_2,       reset_btn_dash_2)
	_connect_action("defense",    set_btn_defense,    reset_btn_defense,    set_btn_defense_2,    reset_btn_defense_2)
	_connect_action("skill",      set_btn_skill,      reset_btn_skill,      set_btn_skill_2,      reset_btn_skill_2)
	_connect_action("ultimate",   set_btn_ultimate,   reset_btn_ultimate,   set_btn_ultimate_2,   reset_btn_ultimate_2)
	_connect_action("assist",     set_btn_assist,     reset_btn_assist,     set_btn_assist_2,     reset_btn_assist_2)


# ==========================================
# —— 信号连接与显示刷新 ——
# ==========================================

func _connect_action(action: String, set_btn: Button, reset_btn: Button, set_btn_2: Button = null, reset_btn_2: Button = null) -> void:
	set_btn.pressed.connect(_on_set_button_pressed.bind(action, set_btn, 0))
	reset_btn.pressed.connect(_on_reset_button_pressed.bind(action, set_btn, 0))
	_update_button_text(action, set_btn, 0)

	if set_btn_2:
		set_btn_2.pressed.connect(_on_set_button_pressed.bind(action, set_btn_2, 1))
	if reset_btn_2:
		reset_btn_2.pressed.connect(_on_reset_button_pressed.bind(action, set_btn_2, 1))
	if set_btn_2:
		_update_button_text(action, set_btn_2, 1)


## 更新按钮显示：slot=0 主键, slot=1 副键
func _update_button_text(action: String, btn: Button, slot: int) -> void:
	var ev := _get_key_event_at_slot(action, slot)
	if ev:
		if ev is InputEventKey:
			var keycode = ev.physical_keycode if ev.physical_keycode != KEY_NONE else ev.keycode
			btn.text = OS.get_keycode_string(keycode)
		elif ev is InputEventMouseButton:
			btn.text = "鼠标 " + str(ev.button_index)
		elif ev is InputEventJoypadButton:
			btn.text = "手柄 " + str(ev.button_index)
	else:
		btn.text = "未绑定"


## 获取某个动作的第 slot 个键盘/鼠标事件
func _get_key_event_at_slot(action: String, slot: int) -> InputEvent:
	var kb_mouse_events: Array = []
	var all_events: Array = InputManager.current_keys.get(action, [])
	for e in all_events:
		if e is InputEventKey or e is InputEventMouseButton:
			kb_mouse_events.append(e)
	if slot < kb_mouse_events.size():
		return kb_mouse_events[slot]
	return null


# ==========================================
# —— 按钮点击事件处理 ——
# ==========================================

func _on_set_button_pressed(action: String, btn: Button, slot: int) -> void:
	if is_listening:
		return
	is_listening = true
	current_action_rebind = action
	current_set_button = btn
	current_bind_slot = slot
	btn.text = "请按键..."
	InputManager.is_gameplay_locked = true


func _on_reset_button_pressed(action: String, set_btn: Button, slot: int) -> void:
	is_listening = false
	InputManager.is_gameplay_locked = false

	var default_ev := _get_default_key_at_slot(action, slot)
	var all_events: Array = InputManager.current_keys.get(action, [])
	var kb_mouse_events: Array = []
	var other_events: Array = []
	for e in all_events:
		if e is InputEventKey or e is InputEventMouseButton:
			kb_mouse_events.append(e)
		else:
			other_events.append(e)

	# 用默认值替换对应 slot，或移除
	if default_ev:
		while kb_mouse_events.size() <= slot:
			kb_mouse_events.append(null)
		kb_mouse_events[slot] = default_ev
	else:
		if slot < kb_mouse_events.size():
			kb_mouse_events.remove_at(slot)

	var new_events: Array = []
	for e in kb_mouse_events:
		if e != null:
			new_events.append(e)
	new_events.append_array(other_events)

	InputManager.rebind_action(action, new_events)
	_update_button_text(action, set_btn, slot)


## 获取动作默认的第 slot 个键盘/鼠标事件
func _get_default_key_at_slot(action: String, slot: int) -> InputEvent:
	if not InputManager.DEFAULT_MAPPINGS.has(action):
		return null
	var kb_mouse: Array = []
	for e in InputManager.DEFAULT_MAPPINGS[action]:
		if e is InputEventKey or e is InputEventMouseButton:
			kb_mouse.append(e)
	if slot < kb_mouse.size():
		return kb_mouse[slot]
	return null


# ==========================================
# —— 核心监听捕获逻辑 ——
# ==========================================

func _input(event: InputEvent) -> void:
	if not is_listening:
		return

	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
		_cancel_listening()
		get_viewport().set_input_as_handled()
		return

	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		get_viewport().set_input_as_handled()

		# 创建纯净事件
		var clean_event: InputEvent
		if event is InputEventKey:
			clean_event = InputEventKey.new()
			clean_event.physical_keycode = event.physical_keycode
		elif event is InputEventMouseButton:
			clean_event = InputEventMouseButton.new()
			clean_event.button_index = event.button_index

		# 分离键盘/鼠标事件 和 手柄事件
		var kb_mouse_events: Array = []
		var other_events: Array = []
		for e in InputManager.current_keys.get(current_action_rebind, []):
			if e is InputEventKey or e is InputEventMouseButton:
				kb_mouse_events.append(e)
			else:
				other_events.append(e)

		# 在对应 slot 插入/替换
		while kb_mouse_events.size() <= current_bind_slot:
			kb_mouse_events.append(null)
		kb_mouse_events[current_bind_slot] = clean_event

		# 重建事件列表：键盘/鼠标在前，手柄在后
		var new_events: Array = []
		for e in kb_mouse_events:
			if e != null:
				new_events.append(e)
		new_events.append_array(other_events)

		InputManager.rebind_action(current_action_rebind, new_events)
		_update_button_text(current_action_rebind, current_set_button, current_bind_slot)

		is_listening = false
		current_action_rebind = ""
		current_set_button = null
		InputManager.is_gameplay_locked = false


func _cancel_listening() -> void:
	is_listening = false
	if current_set_button and current_action_rebind != "":
		_update_button_text(current_action_rebind, current_set_button, current_bind_slot)
	current_action_rebind = ""
	current_set_button = null
	InputManager.is_gameplay_locked = false
