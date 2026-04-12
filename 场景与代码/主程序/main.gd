extends Node

@export var character1:PackedScene
@export var character2:PackedScene
@onready var _1p_pos: Node2D = $"1P位置"
@onready var _2p_pos: Node2D = $"2P位置"
@onready var camera: Camera2D = $镜头
@onready var map: Node2D = $山脉


func _ready():
	var character1_instance = character1.instantiate()
	var character2_instance = character2.instantiate()
	character1_instance.position=_1p_pos.position
	character2_instance.position=_2p_pos.position
	camera.reparent(character1_instance)
	camera.position = Vector2.ZERO
	map.z_index = -1
	var players = [character1_instance,character2_instance]
	# 按顺序分配组
	if players.size() > 0 and players[0].is_in_group("players"):
		players[0].add_to_group("1P")
		players[0].character_data.team="1P"
		print("第一个角色:%s加入:%s"%
		[players[0].character_name,players[0].character_data.team])
	if players.size() > 1 and players[1].is_in_group("players"):
		players[1].add_to_group("2P")
		players[1].character_data.team="2P"
		print("第一个角色:%s加入:%s"%
		[players[1].character_name,players[1].character_data.team])
	
	print("main初始化完成")
	add_child(character1_instance)
	add_child(character2_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
