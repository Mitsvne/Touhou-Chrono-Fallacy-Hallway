extends GameState

func _ready() -> void:
	is_in_game = true  # _ready 设，防止 tscn 反序列化覆盖

@export var settlement_ui_scene: PackedScene 

var _settlement_ui_instance: Node = null

func enter() -> void:
	InputManager.is_gameplay_locked = true
	if settlement_ui_scene:
		_settlement_ui_instance = settlement_ui_scene.instantiate()
		_settlement_ui_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_settlement_ui_instance)

func exit() -> void:
	if is_instance_valid(_settlement_ui_instance):
		_settlement_ui_instance.queue_free()
	_settlement_ui_instance = null
