extends Node

@export var initial_state: GameState

var current_state: GameState
var states: Dictionary = {}

# 历史栈（存储字典，格式如：{"state": "mainmenu", "scene": "res://..."}）
var history_stack: Array[Dictionary] = []
# 黑名单：这些状态属于临时或过渡状态，绝不计入历史
const BLACKLIST_STATES = [STATE_TRANSITION, STATE_OPENING]

# 状态名常量 —— 统一引用，避免硬编码字符串
const STATE_OPENING    = "局内开场"
const STATE_PLAYING    = "局内正常"
const STATE_PAUSED     = "局内暂停"
const STATE_SETTLE     = "局内结算"
const STATE_TRANSITION = "切换"
const STATE_MAIN_MENU  = "主菜单"
const STATE_LEVEL_SEL  = "关卡选择"
const STATE_CHARACTER  = "人物面板"
const STATE_SETTINGS   = "设置"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		if child is GameState:
			states[child.name.to_lower()] = child
			child.manager = self
	# 确保开场状态已注册（兜底：若 tscn 中未放置则自动创建）
	if not states.has(STATE_OPENING):
		var opening_state = load("res://场景与代码/主程序/主体类/全局管理器/游戏状态管理器/局内开场.gd").new()
		opening_state.name = STATE_OPENING
		opening_state.manager = self
		add_child(opening_state)
		states[STATE_OPENING] = opening_state
	if initial_state:
		change_state(initial_state.name.to_lower())
	elif not states.is_empty():
		# 兜底：未设置初始状态时，优先进主菜单，否则取第一个
		var fallback = states.get(STATE_MAIN_MENU)
		if not fallback:
			fallback = states.values()[0]
		change_state(fallback.name.to_lower())


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	# 局内状态统一响应暂停键
	if current_state and current_state.is_in_game:
		if InputManager.is_action_just_pressed("pause"):
			var current_name = current_state.name.to_lower()
			if current_name == STATE_PAUSED:
				# 已在暂停 → 返回之前的状态
				var ps = states.get(STATE_PAUSED)
				change_state(ps.get_return_state() if ps else STATE_PLAYING)
			else:
				# 进入暂停，告诉暂停返回到哪个状态
				var ps = states.get(STATE_PAUSED)
				if ps: ps.set_return_state(current_name)
				change_state(STATE_PAUSED)


## 切换至下一个状态
func change_state(state_name: String, record_history: bool = true) -> void:
	var new_state = states.get(state_name.to_lower())
	if not new_state or current_state == new_state:
		return

	# 注：局内历史不再自动清除，改为在离开游戏的 UI 按钮中显式调用 purge_in_game_history()

	if current_state and record_history:
		var current_name = current_state.name.to_lower()
		if not current_name in BLACKLIST_STATES:
			var current_scene = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
			history_stack.append({
				"state": current_name,
				"scene": current_scene
			})

	if current_state:
		current_state.exit()
	var old_state = current_state
	current_state = new_state
	current_state.enter()
	print("状态切换：%s -> %s | 当前历史栈深度: %d" % [old_state.name if old_state else "None", current_state.name, history_stack.size()])


## 结束开场序列（由关卡脚本在开场逻辑完成后调用）
func end_opening() -> void:
	var s = states.get(STATE_OPENING)
	if s and s.has_method("end_opening"):
		s.end_opening()


## 清理历史栈中的局内条目（离开游戏时显式调用）
func purge_in_game_history() -> void:
	var filtered: Array[Dictionary] = []
	for entry in history_stack:
		var state_name = entry["state"]
		var s = states.get(state_name)
		if s and s.is_in_game:
			continue
		filtered.append(entry)
	history_stack = filtered


## 切换至下一个状态和场景
func transition_to(target_state: String, scene_path: String = "", record_history: bool = true) -> void:
	var transition_state = get_node_or_null(STATE_TRANSITION)
	if not transition_state:
		push_error("错误：未在 GameStateManager 下找到名为 '切换' 的子节点！")
		return
	transition_state.next_scene_path = scene_path
	transition_state.next_state_name = target_state
	change_state(STATE_TRANSITION, record_history)


## 返回上一个状态和场景
## @param allowed_states 可选白名单，只返回到列表中的状态，其余跳过
func go_back(allowed_states: Array[String] = []) -> void:
	while not history_stack.is_empty():
		var previous = history_stack.pop_back()
		var target_state = previous["state"]
		# 有白名单且当前条目不在白名单中 → 跳过
		if not allowed_states.is_empty() and not target_state in allowed_states:
			continue
		var target_scene = previous["scene"]
		var current_scene = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
		if target_scene != "" and target_scene != current_scene:
			var transition_node = states.get(STATE_TRANSITION)
			if transition_node:
				transition_node.next_scene_path = target_scene
				transition_node.next_state_name = target_state
				change_state(STATE_TRANSITION, false)
		else:
			change_state(target_state, false)
		return
	# 历史栈为空：回退到白名单第一个状态
	if not allowed_states.is_empty():
		change_state(allowed_states[0], false)
		return
	print("没有更多的历史记录可以返回！")


## 获取当前状态
func get_current_state_name() -> String:
	if current_state:
		return current_state.name.to_lower()
	return ""


## 是否为某状态
func is_current_state(state_name: String) -> bool:
	if not current_state:
		return false
	return current_state.name.to_lower() == state_name.to_lower()
