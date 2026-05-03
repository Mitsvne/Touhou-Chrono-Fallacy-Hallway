extends Node

@export var character1:PackedScene
@export var character2:PackedScene
@export var result_scene:PackedScene

@onready var _1p_pos: Node2D = $"1P位置"
@onready var _2p_pos: Node2D = $"2P位置"
@onready var camera: Camera2D = $镜头
@onready var arrow: Sprite2D = $ui/箭头


@onready var map: Node2D = $山脉

var character1_instance : Node2D
var character2_instance : Node2D
# 可调整的偏移量，避免箭头紧贴边缘
const EDGE_MARGIN := 20.0

func _ready():
	character1_instance = character1.instantiate()
	character2_instance = character2.instantiate()
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
	character1_instance.character_main.character_is_dead.connect(game_over_fail)
	if character2_instance.bt_player.active:
		character2_instance.character_ai_main.character_is_dead.connect(game_over_victory)
	else:
		character2_instance.character_main.character_is_dead.connect(game_over_victory)
	arrow.player=character1_instance
	arrow.enemy=character2_instance
	


func _physics_process(_delta: float) -> void:
	pass

## 玩家胜利结算
func game_over_victory(team):
	print("游戏胜利，%s死亡"%[team])
	add_result_scene("成功")

## 玩家胜利结算
func game_over_fail(team):
	print("游戏失败，%s死亡"%[team])
	add_result_scene("失败")

## 添加结算页面
func  add_result_scene(result:String):
	var result_instance = result_scene.instantiate()
	result_instance.result=result
	add_child(result_instance)
