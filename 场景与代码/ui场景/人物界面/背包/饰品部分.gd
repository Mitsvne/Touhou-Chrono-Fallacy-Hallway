# accessory_menu.gd
extends Control

# 【手动在检查器里拖入你做好的 3 个装备槽按钮】
@export var equipped_slots: Array[AccessorySlot] = []

# 【手动拖入背包列表容器】
@export var inventory_container: Control

# 假设你的背包数据存储在某个全局单例、或者能从玩家身上获取
# 这里为了演示，模拟一个玩家拥有的饰品数组
var player_inventory: Array[AccessoryData] = []

# 记录当前玩家点击了哪个装备槽（准备更换它）
var selected_equipped_slot_index: int = -1

func _ready() -> void:
	# 1. 初始化装备槽的属性
	for i in range(equipped_slots.size()):
		equipped_slots[i].is_equipped_slot = true
		equipped_slots[i].slot_index = i
		# 监听装备槽点击事件
		equipped_slots[i].pressed.connect(_on_equipped_slot_pressed.bind(i))
	
	# 2. 刷新整个面板显示
	_refresh_ui()

# 刷新界面的主函数
func _refresh_ui() -> void:
	# 获取玩家的装备管理器（请根据你游戏的具体节点路径修改）
	# 假设你在全局可以通过某个方式拿到 player 节点
	var eq_manager = _get_equipment_manager()
	if not eq_manager: return
	
	# A. 刷新身上已装备的格子
	for i in range(equipped_slots.size()):
		var data = eq_manager.slots[i]
		equipped_slots[i].display(data)
		
	# B. 刷新背包里的可选列表
	_update_inventory_list()

# 更新背包列表显示
func _update_inventory_list() -> void:
	# 清空旧列表
	for child in inventory_container.get_children():
		child.queue_free()
		
	# 获取玩家当前拥有的所有饰品数据（这里只是示例数据，你需要对接你的背包系统）
	player_inventory = _get_player_owned_accessories()
	
	for data in player_inventory:
		# 实例化一个新的格子（你可以直接用代码新建 Button，也可以 load() 你做好的槽位预制体）
		var slot_btn = AccessorySlot.new()
		slot_btn.custom_minimum_size = Vector2(100, 40)
		slot_btn.display(data)
		
		# 监听背包格子的点击：点击意味着“我想把这个饰品装备到当前选中的槽位”
		slot_btn.pressed.connect(_on_inventory_item_pressed.bind(data))
		inventory_container.add_child(slot_btn)

# ==========================================
# —— 交互逻辑 ——
# ==========================================

# 玩家点击了身上的某个装备槽
func _on_equipped_slot_pressed(slot_index: int) -> void:
	selected_equipped_slot_index = slot_index
	print("选中了第 ", slot_index + 1, " 个装备槽，请在背包里选择要替换的饰品")
	
	# 【优化体验】可选逻辑：如果这个槽位本来就有装备，可以做成“再点一次就卸下”
	var eq_manager = _get_equipment_manager()
	if eq_manager and eq_manager.slots[slot_index] != null:
		pass
		# 这里为了简化，你可以加一个右键直接卸下，或者弹窗，这里暂只做选中标记。

# 玩家在背包里点击了某件饰品
func _on_inventory_item_pressed(accessory: AccessoryData) -> void:
	# 如果玩家没有先选中身上的槽位，默认装到第一个空槽，或者提示玩家
	if selected_equipped_slot_index == -1:
		selected_equipped_slot_index = _get_first_empty_slot()
		if selected_equipped_slot_index == -1:
			print("请先点击选择一个你想替换的装备槽！")
			return
			
	var eq_manager = _get_equipment_manager()
	if eq_manager:
		# 调用上一问我们写好的底层逻辑，穿上装备（会自动触发被动效果！）
		eq_manager.equip_accessory(accessory, selected_equipped_slot_index)
		
		# 穿好后，重置选中状态并刷新 UI 展现
		selected_equipped_slot_index = -1
		_refresh_ui()

# ==========================================
# —— 辅助函数（需要根据你的项目结构微调） ——
# ==========================================

func _get_equipment_manager() -> Node:
	# 示例：假设场景里有个名为 "Player" 的节点，下面挂着 "EquipmentManager"
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("EquipmentManager"):
		return player.get_node("EquipmentManager")
	return null

func _get_player_owned_accessories() -> Array[AccessoryData]:
	# 这里的逻辑应该去找你的全局背包单例或者玩家节点，获取他捡到了哪些饰品
	# 目前先返回一些测试资源，供你测试 UI
	return [] 

func _get_first_empty_slot() -> int:
	var eq_manager = _get_equipment_manager()
	if eq_manager:
		for i in range(eq_manager.slots.size()):
			if eq_manager.slots[i] == null:
				return i
	return -1
