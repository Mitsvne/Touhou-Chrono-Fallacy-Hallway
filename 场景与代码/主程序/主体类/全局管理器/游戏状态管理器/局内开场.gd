extends GameState
## 关卡开场状态 —— 锁定玩家操作，播放动画/对话，完成后进入正常

func _init() -> void:
	is_in_game = true #锁定玩家操作，播放入场动画/对话，完成后进入正常

## 开场持续时间（秒），设为 0 或负数则需手动调用 end_opening()
@export var duration: float = 0.0

var _active: bool = false
var _timer: float = 0.0

func enter() -> void:
	# 锁定玩家输入，但保持场景运行（动画可播放）
	InputManager.is_gameplay_locked = true
	get_tree().paused = false
	_timer = 0.0
	_active = true
	EventBus.opening_started.emit()
	print("开场状态：进入开场，玩家输入已锁定")


func update(delta: float) -> void:
	if not _active:
		return
	# 计时器模式：到时自动结束
	if duration > 0.0:
		_timer += delta
		if _timer >= duration:
			end_opening()
	# 暂停键由 GameStateManager._process 统一接管


## 手动结束开场，切换到正常状态
func end_opening() -> void:
	if not _active:
		return
	_active = false
	print("开场状态：开场结束，切换到正常")
	EventBus.opening_ended.emit()
	manager.change_state("局内正常")


func exit() -> void:
	_active = false
