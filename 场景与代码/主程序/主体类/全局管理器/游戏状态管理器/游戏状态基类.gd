class_name GameState
extends Node

## 是否为局内状态（局内状态统一响应暂停键，切到局外时自动清理局内历史）
@export var is_in_game: bool = false

# 持有管理器的引用，方便状态内部调用切换
var manager: Node

# 当进入该状态时触发
func enter() -> void:
	pass

# 当离开该状态时触发
func exit() -> void:
	pass

# 该状态下的帧更新（替代原来的全局 _process）
func update(_delta: float) -> void:
	pass
