extends Node

enum State { 正常, 暂停, 结算 }
signal state_changed(new_state: State)
var _current_state: State = State.正常

var current_state: State:
	get:
		return _current_state
	set(new_state):
		if _current_state == new_state:
			return
		print("游戏状态：%s => %s"%[State.keys()[_current_state],State.keys()[new_state]])
		_current_state = new_state
		if _current_state==State.正常:
			InputManager.is_gameplay_locked=false
		else:
			InputManager.is_gameplay_locked=true
		state_changed.emit(_current_state)

func set_pause(pause: bool):
	if pause and _current_state == State.正常:
		current_state = State.暂停
	elif not pause and _current_state == State.暂停:
		current_state = State.正常

func set_result(result: bool):
	if result and _current_state in [State.正常, State.暂停]:
		# 结算前如果正在暂停，通常需要先解除暂停
		if _current_state == State.暂停:
			get_tree().paused = false
		current_state = State.结算
	elif not result and _current_state == State.结算:
		current_state = State.正常
