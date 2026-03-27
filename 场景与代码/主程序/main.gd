extends Node

@onready var lm: CharacterBody2D = $灵梦
@onready var lh: CharacterBody2D = $拉赫

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
		#print(players[0].team)
		#print("第一个角色:%s加入%s"%[players[0].character_name,players[0].get_groups()[1]])
	if players.size() > 1:
		players[1].add_to_group("2P")
		players[1].team="2P"
		#print(players[1].team)
		#print("第二个角色:%s加入%s"%[players[1].character_name,players[1].get_groups()[1]])



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
