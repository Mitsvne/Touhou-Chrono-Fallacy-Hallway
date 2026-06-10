extends Node
## 角色状态机管理器基类 —— _ready 收集状态，start() 启动
## 子类覆写 init_states() 和 check_special_inputs()
class_name CharacterStateMachine

## 拥有此状态机的角色主体引用（由 Character_Main 在 _ready 中设置）
var character_main: Node = null

## 角色组件引用（由 Character_Main 设置，供所有 State 访问）
var character: CharacterBody2D = null
var character_data: Character_Data = null
var character_ctrler: Character_Ctrler = null
var anplayer: AnimationPlayer = null

## 当前状态
var current_state: CharacterState = null

## 状态字典 { "IdleState": CharacterState节点, ... }
var states: Dictionary = {}

## 用于持久化的速度（惯性移动）
var current_velocity: Vector2 = Vector2.ZERO

## 重力
var gravity: float = ProjectSettings.get("physics/2d/default_gravity") as float


func _ready() -> void:
	_collect_states()


## 收集状态节点 —— 优先扫描编辑器中已放置的子节点，没有则调用 init_states()
func _collect_states() -> void:
	# 扫描编辑器中已放置的 CharacterState 子节点
	for child in get_children():
		if child is CharacterState:
			child.machine = self
			states[child.name] = child
	# 没有编辑器放置的状态 → 调用子类 init_states() 程序化创建（兜底）
	if states.is_empty():
		init_states()


## 程序化创建状态 —— 子类覆写此方法
func init_states() -> void:
	pass


## 注册一个状态节点（init_states 中调用）
func _register_state(state_name: String, state: CharacterState) -> void:
	state.name = state_name
	state.machine = self
	add_child(state)
	states[state_name] = state


## 由 Character_Main 在设置完所有 refs 后调用，启动状态机
func start(initial_state_name: String = "IdleState") -> void:
	# 兜底：如果 _ready 还没跑（程序化创建且 _ready 被延迟），手动收集
	if states.is_empty():
		_collect_states()
	if states.has(initial_state_name):
		change_state(initial_state_name)
	else:
		printerr("CharacterStateMachine: 初始状态 '%s' 不存在" % initial_state_name)


## 切换到指定状态
func change_state(state_name: String) -> void:
	var new_state: CharacterState = states.get(state_name, null)
	if not new_state:
		printerr("CharacterStateMachine: 状态 '%s' 不存在" % state_name)
		return
	if current_state == new_state:
		return

	var prev_state = current_state
	if current_state:
		current_state.exit(new_state)

	current_state = new_state
	current_state.enter(prev_state)

	var from_name = prev_state.name if prev_state else "None"
	print("状态转换: %s → %s" % [from_name, state_name])


## 每物理帧由 Character_Main 调用
func physics_process(delta: float) -> void:
	if not current_state:
		return

	# 全局死亡检测 —— 任何状态都能瞬间切到死亡
	if character_main and character_main.has_method("is_dead"):
		if character_main.is_dead() and current_state.name != "DeadState":
			change_state("DeadState")
			if current_state and current_state.name == "DeadState":
				current_state.physics_update(delta)
			return

	# 检查当前状态的转换
	var next_name: String = current_state.get_next_state()
	if next_name != "" and states.has(next_name):
		change_state(next_name)

	# 驱动当前状态
	if current_state:
		current_state.physics_update(delta)


## idle 和 move 共用的特殊输入检测 —— 子类必须覆写
## 返回非空字符串表示要切换到的状态名
func check_special_inputs() -> String:
	return ""


## 返回当前状态名
func get_current_state_name() -> String:
	if current_state:
		return current_state.name
	return ""


## 判断当前是否某状态
func is_current_state(state_name: String) -> bool:
	if not current_state:
		return false
	return current_state.name == state_name
