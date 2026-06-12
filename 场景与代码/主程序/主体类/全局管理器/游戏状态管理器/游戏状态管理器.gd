extends Node

@export var initial_state: GameState

var current_state: GameState
var states: Dictionary = {}

# 历史栈（存储字典，格式如：{"state": "mainmenu", "scene": "res://..."}）
var history_stack: Array[Dictionary] = []
# 黑名单：这些状态属于临时或过渡状态，绝不计入历史
const BLACKLIST_STATES = ["切换", "开场"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		if child is GameState:
			states[child.name.to_lower()] = child
			child.manager = self
	if initial_state:
		change_state(initial_state.name.to_lower())

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

## 切换至下一个状态
func change_state(state_name: String, record_history: bool = true) -> void:
	var new_state = states.get(state_name.to_lower())
	if not new_state or current_state == new_state:
		return
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
func go_back() -> void:
	if history_stack.is_empty():
		print("没有更多的历史记录可以返回！")
		return
	# 1. 弹出最近的一条历史记录
	var previous = history_stack.pop_back()
	var target_state = previous["state"]
	var target_scene = previous["scene"]
	var current_scene = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	# 2. 判断是否需要跨场景回退
	if target_scene != "" and target_scene != current_scene:
		var transition_node = states.get("切换")
		if transition_node:
			transition_node.next_scene_path = target_scene
			transition_node.next_state_name = target_state
			change_state("切换", false)
	else:
		change_state(target_state, false)

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
