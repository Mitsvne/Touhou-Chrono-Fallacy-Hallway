extends Control

# 用于记录当前是否正在等待玩家按下新按键
var is_listening := false
var current_action_rebind := ""
var current_set_button: Button = null

@export var set_btn_move_up :Button
@export var reset_btn_move_up = Button
@export var set_btn_move_down :Button
@export var reset_btn_move_down = Button
@export var set_btn_move_left :Button
@export var reset_btn_move_left = Button
@export var set_btn_move_right :Button
@export var reset_btn_move_right = Button
@export var set_btn_attack :Button
@export var reset_btn_attack = Button
@export var set_btn_dash :Button
@export var reset_btn_dash = Button
@export var set_btn_skill :Button
@export var reset_btn_skill = Button
@export var set_btn_ultimate :Button
@export var reset_btn_ultimate = Button
@export var set_btn_assist :Button
@export var reset_btn_assist = Button

func _ready() -> void:
	# 1. 初始化绑定：将你的按钮、对应的动作名连接到逻辑函数上
	_connect_action("move_up", set_btn_move_up, reset_btn_move_up)
	_connect_action("move_down", set_btn_move_down, reset_btn_move_down)
	_connect_action("move_left", set_btn_move_left, reset_btn_move_left)
	_connect_action("move_right", set_btn_move_right, reset_btn_move_right)
	_connect_action("attack", set_btn_attack, reset_btn_attack)
	_connect_action("dash", set_btn_dash, reset_btn_dash)
	_connect_action("skill", set_btn_skill, reset_btn_skill)
	_connect_action("ultimate", set_btn_ultimate, reset_btn_ultimate)
	_connect_action("assist", set_btn_assist, reset_btn_assist)


## ==========================================
## —— 信号连接与显示刷新 ——
## ==========================================

## 按钮信号连接
func _connect_action(action: String, set_btn: Button, reset_btn: Button) -> void:
	# 连接“设置按键”按钮
	set_btn.pressed.connect(_on_set_button_pressed.bind(action, set_btn))
	# 连接“重置按键”按钮
	reset_btn.pressed.connect(_on_reset_button_pressed.bind(action, set_btn))
	# 初始化时，刷新一次按钮上显示的按键名称
	_update_button_text(action, set_btn)

## 更新按钮显示内容
func _update_button_text(action: String, btn: Button) -> void:
	var events: Array = InputManager.current_keys.get(action, [])
	if events.size() > 0:
		var ev = events[0] # 取绑定的第一个按键用于显示
		if ev is InputEventKey:
			var keycode = ev.physical_keycode if ev.physical_keycode != KEY_NONE else ev.keycode
			btn.text = OS.get_keycode_string(keycode)
		elif ev is InputEventMouseButton:
			btn.text = "鼠标 " + str(ev.button_index)
		elif ev is InputEventJoypadButton:
			btn.text = "手柄 " + str(ev.button_index)
	else:
		btn.text = "未绑定"


## ==========================================
## —— 按钮点击事件处理 ——
## ==========================================

## 设置按键按下时
func _on_set_button_pressed(action: String, btn: Button) -> void:
	if is_listening:
		return # 防误触：正在监听其他按键时，不响应新的点击
	is_listening = true
	current_action_rebind = action
	current_set_button = btn
	btn.text = "请按键..."
	InputManager.is_gameplay_locked = true # 锁定游戏内输入

## 重置按键按下时
func _on_reset_button_pressed(action: String, set_btn: Button) -> void:
	# 取消可能正在进行的监听
	is_listening = false
	InputManager.is_gameplay_locked = false
	# 从 InputManager 获取该动作的默认事件
	if InputManager.DEFAULT_MAPPINGS.has(action):
		var default_events = InputManager.DEFAULT_MAPPINGS[action]
		# 调用管理器的 rebind_action 存盘并生效
		InputManager.rebind_action(action, default_events)
		# 刷新文本显示
		_update_button_text(action, set_btn)


## ==========================================
## —— 核心监听捕获逻辑 ——
## ==========================================

## 监听输入
func _input(event: InputEvent) -> void:
	if not is_listening:
		return
	# 允许用 ESC 键取消本次绑定（如果不想要可以删掉这部分）
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
		_cancel_listening()
		get_viewport().set_input_as_handled()
		return
	# 只捕获键盘和鼠标按压
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		get_viewport().set_input_as_handled() # 吞掉输入，防止透传到游戏里
		# 剥离无用信息，创建纯净的事件
		var clean_event: InputEvent
		if event is InputEventKey:
			clean_event = InputEventKey.new()
			clean_event.physical_keycode = event.physical_keycode
		elif event is InputEventMouseButton:
			clean_event = InputEventMouseButton.new()
			clean_event.button_index = event.button_index
		# [关键点] 如果原动作同时绑定了手柄和键盘，我们只想覆盖键盘/鼠标，保留手柄：
		var new_events: Array = [clean_event]
		var old_events = InputManager.current_keys.get(current_action_rebind, [])
		for old_ev in old_events:
			# 如果旧绑定里有手柄设置，保留它
			if old_ev is InputEventJoypadButton or old_ev is InputEventJoypadMotion:
				new_events.append(old_ev)
		# 提交新绑定
		InputManager.rebind_action(current_action_rebind, new_events)
		_update_button_text(current_action_rebind, current_set_button)
		# 退出监听
		is_listening = false
		current_action_rebind = ""
		current_set_button = null
		InputManager.is_gameplay_locked = false

## 取消监听输入
func _cancel_listening() -> void:
	is_listening = false
	if current_set_button and current_action_rebind != "":
		_update_button_text(current_action_rebind, current_set_button)
	current_action_rebind = ""
	current_set_button = null
	InputManager.is_gameplay_locked = false
