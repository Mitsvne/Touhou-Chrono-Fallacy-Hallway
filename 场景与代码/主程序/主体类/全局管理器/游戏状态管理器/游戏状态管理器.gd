extends Node

@export var initial_state: GameState

var current_state: GameState
var states: Dictionary = {}

# 历史栈（存储字典，格式如：{"state": "mainmenu", "scene": "res://..."}）
var history_stack: Array[Dictionary] = []
# 黑名单：这些状态属于临时或过渡状态，绝不计入历史
const BLACKLIST_STATES = ["切换", "局内开场"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		if child is GameState:
			states[child.name.to_lower()] = child
			child.manager = self
	# 确保开场状态已注册（兜底：若 tscn 中未放置则自动创建）
	if not states.has("局内开场"):
		var opening_state = load("res://场景与代码/主程序/主体类/全局管理器/游戏状态管理器/开场.gd").new()
		opening_state.name = "局内开场"
		opening_state.manager = self
		add_child(opening_state)
		states["局内开场"] = opening_state
	if initial_state:
		change_state(initial_state.name.to_lower())


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	# 局内状态统一响应暂停键
	if current_state and current_state.is_in_game:
		if InputManager.is_action_just_pressed("pause"):
			var current_name = current_state.name.to_lower()
			if current_name == "局内暂停":
				# 已在暂停 → 返回之前的状态
				var ps = states.get("局内暂停")
				change_state(ps._return_state if ps else "局内正常")
			else:
				# 进入暂停，告诉暂停返回到哪个状态
				var ps = states.get("局内暂停")
				if ps: ps._return_state = current_name
				change_state("局内暂停")


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
func transition_to(target_state: String, scene_path: String = "") -> void:
	var transition_state = get_node_or_null("切换")
	if not transition_state:
		push_error("错误：未在 GameStateManager 下找到名为 '切换' 的子节点！")
		return
	transition_state.next_scene_path = scene_path
	transition_state.next_state_name = target_state
	change_state("切换")


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
			var transition_node = states.get("切换")
			if transition_node:
				transition_node.next_scene_path = target_scene
				transition_node.next_state_name = target_state
				change_state("切换", false)
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
