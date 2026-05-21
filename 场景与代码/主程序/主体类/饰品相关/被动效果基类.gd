class_name AccessoryEffect
extends Resource

# 当饰品被装备时调用
func on_equip(_target: Node) -> void:
	pass

# 当饰品被卸下时调用（必须把加的属性减回去，或者断开信号，防止内存泄漏）
func on_unequip(_target: Node) -> void:
	pass
