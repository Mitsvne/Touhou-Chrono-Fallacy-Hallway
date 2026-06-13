extends GameState

func _ready() -> void:
	is_in_game = true  # _ready 设，防止 tscn 反序列化覆盖

@export var pause_ui_scene: PackedScene

# 常驻内存的 UI 实例缓存
var _pause_ui_instance: Node = null
var _return_state: String = "局内正常"  # 暂停恢复时返回的状态

func get_return_state() -> String:
	return _return_state

func set_return_state(s: String) -> void:
	_return_state = s

func enter() -> void:
	InputManager.is_gameplay_locked = true
	get_tree().paused = true
	if not is_instance_valid(_pause_ui_instance) and pause_ui_scene:
		_pause_ui_instance = pause_ui_scene.instantiate()
		_pause_ui_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_pause_ui_instance)
	if _pause_ui_instance:
		_pause_ui_instance.show()
		if _pause_ui_instance.has_method("init"):
			_pause_ui_instance.init()

func exit() -> void:
	# 局内暂停/恢复期间仅隐藏，不销毁（避免频繁重建）
	if is_instance_valid(_pause_ui_instance):
		_pause_ui_instance.hide()

## 退出局内时彻底销毁暂停 UI
func destroy_ui() -> void:
	if is_instance_valid(_pause_ui_instance):
		_pause_ui_instance.queue_free()
	_pause_ui_instance = null

# update 移除 —— 暂停键由 GameStateManager._process 统一接管
