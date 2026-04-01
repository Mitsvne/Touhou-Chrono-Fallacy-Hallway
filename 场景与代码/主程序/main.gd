extends Node


func _ready():
	var players = []
	# 收集所有直接子节点中类型为 CharacterBody2D 的节点
	for child in get_children():
		if child is CharacterBody2D:
			players.append(child)
	# 按顺序分配组
	if players.size() > 0:
		players[0].add_to_group("1P")
		players[0].team="1P"
		players[0].character_data.team="1P"
		players[0].character_data.direction=1
		#print(players[0].character_data.direction)
		#print(players[0].character_data.team)
		#print("第一个角色:%s加入%s"%[players[0].character_name,players[0].get_groups()[1]])
	if players.size() > 1:
		players[1].add_to_group("2P")
		players[1].team="2P"
		players[1].character_data.team="2P"
		players[1].character_data.direction=-1
		#print(players[1].character_data.direction)
		#print(players[1].team)
		#print("第二个角色:%s加入%s"%[players[1].character_name,players[1].get_groups()[1]])
	#print("main初始化完成")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	await get_tree().process_frame
	get_tree().reload_current_scene()
