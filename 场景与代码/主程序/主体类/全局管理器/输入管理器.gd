extends Node

const SETTINGS_PATH := "user://input_settings.cfg"

# 是否锁定玩家的局内操作输入
var is_gameplay_locked := false : 
	set(value):
		is_gameplay_locked = value
		if is_gameplay_locked:
			# 锁定瞬间，可以根据需要释放一些持续按住的状态，防止角色“卡死”在跑步状态
			pass

# 拦截白名单：即使在全局锁定时，这些动作依然允许被触发（例如暂停键、UI操作）
var whitelist_actions: Array[String] = ["pause", "ui_accept", "ui_cancel","ui_up","ui_down","ui_left","ui_right"]
var current_keys: Dictionary = {}
var DEFAULT_MAPPINGS: Dictionary = {}

func _init() -> void:
	_initialize_default_mappings()

func _ready() -> void:
	load_keybindings()

func _initialize_default_mappings() -> void:
	var key := func(keycode: Key) -> InputEventKey:
		var ev := InputEventKey.new()
		ev.keycode = keycode
		return ev
	
	var mouse := func(button_index: MouseButton) -> InputEventMouseButton:
		var ev := InputEventMouseButton.new()
		ev.button_index = button_index
		return ev
		
	var joy_btn := func(btn_index: JoyButton) -> InputEventJoypadButton:
		var ev := InputEventJoypadButton.new()
		ev.button_index = btn_index
		return ev

	var joy_axis := func(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
		var ev := InputEventJoypadMotion.new()
		ev.axis = axis
		ev.axis_value = value
		return ev

	DEFAULT_MAPPINGS = {
		"interact":   [key.call(KEY_E)],
		"pause":      [key.call(KEY_ESCAPE), joy_btn.call(JOY_BUTTON_START)],
		
		"move_left":  [key.call(KEY_A), joy_axis.call(JOY_AXIS_LEFT_X, -1.0)],
		"move_right": [key.call(KEY_D), joy_axis.call(JOY_AXIS_LEFT_X, 1.0)],
		"move_up":    [key.call(KEY_W), joy_axis.call(JOY_AXIS_LEFT_Y, -1.0)],
		"move_down":  [key.call(KEY_S), joy_axis.call(JOY_AXIS_LEFT_Y, 1.0)],
		"attack":     [key.call(KEY_J), key.call(KEY_1), mouse.call(MOUSE_BUTTON_LEFT)],
		"dash":       [key.call(KEY_L), key.call(KEY_3), mouse.call(MOUSE_BUTTON_RIGHT)],
		"skill":      [key.call(KEY_U), key.call(KEY_4)],
		"ultimate":   [key.call(KEY_I), key.call(KEY_5)],
		"assist":     [key.call(KEY_O), key.call(KEY_6)],
		
		"move_left_AI":  [key.call(KEY_LEFT)],
		"move_right_AI": [key.call(KEY_RIGHT)],
		"move_up_AI":    [key.call(KEY_UP)],
		"move_down_AI":  [key.call(KEY_DOWN)],
		"skill1_AI":     [key.call(KEY_KP_1)],
		"skill2_AI":     [key.call(KEY_KP_2)],
		"skill3_AI":     [key.call(KEY_KP_3)],
		"skill4_AI":     [key.call(KEY_KP_4)],
		"ultimate_AI":   [key.call(KEY_KP_5)]
	}

func load_keybindings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		_apply_defaults()
		save_keybindings()
		return

	for action in DEFAULT_MAPPINGS.keys():
		var events: Array = config.get_value("input", action, [])
		if events.is_empty():
			events = DEFAULT_MAPPINGS[action]
		_set_action_events(action, events)
	_update_current_keys()

func reset_to_defaults() -> void:
	_apply_defaults()
	save_keybindings()

func rebind_action(action: String, events: Array) -> void:
	if not DEFAULT_MAPPINGS.has(action):
		push_warning("试图绑定一个未定义的动作: " + action)
		return
	_set_action_events(action, events)
	_update_current_keys()
	save_keybindings()

func save_keybindings() -> void:
	var config := ConfigFile.new()
	for action in current_keys.keys():
		var events: Array = InputMap.action_get_events(action)
		config.set_value("input", action, events)
	var err := config.save(SETTINGS_PATH)
	if err != OK:
		push_error("无法保存按键绑定: " + SETTINGS_PATH)

func _apply_defaults() -> void:
	for action in DEFAULT_MAPPINGS.keys():
		_set_action_events(action, DEFAULT_MAPPINGS[action])
	_update_current_keys()

func _set_action_events(action: String, events: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	for ev in events:
		if ev is InputEvent:
			InputMap.action_add_event(action, ev)

func _update_current_keys() -> void:
	current_keys.clear()
	for action in DEFAULT_MAPPINGS.keys():
		current_keys[action] = InputMap.action_get_events(action)


# ==========================================
# —— 安全的对外输入接口（核心拦截逻辑） ——
# ==========================================

## 内部核心过滤函数：判断当前动作是否应该被拦截
func _is_blocked(action: String) -> bool:
	# 如果没有开启锁定，放行
	if not is_gameplay_locked:
		return false
	# If 开启了锁定，且动作不在白名单里，拦截（返回 true）
	return not whitelist_actions.has(action)


func is_action_just_pressed(action: String) -> bool:
	var result = Input.is_action_just_pressed(action)
	if _is_blocked(action):
		return false
	return result


func is_action_pressed(action: String) -> bool:
	if _is_blocked(action): 
		return false
	return Input.is_action_pressed(action)


func is_action_just_released(action: String) -> bool:
	if _is_blocked(action): 
		return false
	return Input.is_action_just_released(action)


func get_axis(negative_action: String, positive_action: String) -> float:
	# 只要参与计算的有任意一个动作被拦截，就返回 0.0
	if _is_blocked(negative_action) or _is_blocked(positive_action):
		return 0.0
	return Input.get_axis(negative_action, positive_action)


func get_vector(negative_x: String, positive_x: String, negative_y: String, positive_y: String, deadzone: float = -1.0) -> Vector2:
	# 只要方向轴被拦截，直接返回零向量
	if _is_blocked(negative_x) or _is_blocked(positive_x) or _is_blocked(negative_y) or _is_blocked(positive_y):
		return Vector2.ZERO
	return Input.get_vector(negative_x, positive_x, negative_y, positive_y, deadzone)
