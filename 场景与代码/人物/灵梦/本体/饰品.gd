extends Node

# 假设角色可以带 3 个饰品
var slots: Array[AccessoryData] = [null, null, null]
@onready var player = get_parent() # 假设该节点是 Player 的直接子节点

# 装备饰品到指定槽位
func equip_accessory(accessory: AccessoryData, slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
		
	# 如果该槽位本来就有饰品，先卸下来
	if slots[slot_index] != null:
		unequip_accessory(slot_index)
		
	# 放入新饰品
	slots[slot_index] = accessory
	
	# 激活该饰品的所有被动效果
	for effect in accessory.passive_effects:
		effect.on_equip(player)
	print("成功装备饰品: ", accessory.accessory_name)

# 卸下指定槽位的饰品
func unequip_accessory(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
		
	var accessory = slots[slot_index]
	
	# 逆向执行，让所有被动效果失效
	for effect in accessory.passive_effects:
		effect.on_unequip(player)
		
	slots[slot_index] = null
	print("卸下了饰品: ", accessory.accessory_name)
