extends Node

@export var character1:PackedScene
@export var character2:PackedScene
@export var result_scene:PackedScene
@export var pause_scene:PackedScene

@onready var _1p_pos: Node2D = $"1P位置"
@onready var _2p_pos: Node2D = $"2P位置"
@onready var camera: Camera2D = $镜头
@onready var arrow: Sprite2D = $ui/箭头
@onready var map: Node2D = $山脉
@onready var bar1: Control = $ui/ui血条人物
@onready var bar2: Control = $ui/ui血条boss

var character1_instance : Node2D
var character2_instance : Node2D
# 可调整的偏移量，避免箭头紧贴边缘
var custom_time: float = 0.0
const EDGE_MARGIN := 20.0

func _ready():
	GameState.current_state = GameState.State.正常   # 强制设为正常
	add_pause_scene()   # 添加暂停页面并隐藏
	# 添加人物
	character1_instance = character1.instantiate()
	character2_instance = character2.instantiate()
	character1_instance.position=_1p_pos.position
	character2_instance.position=_2p_pos.position
	camera.reparent(character1_instance)
	camera.position = Vector2.ZERO
	map.z_index = -1
	var players = [character1_instance,character2_instance]
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
	# 指向箭头与血条
	arrow.player=character1_instance
	arrow.enemy=character2_instance
	bar1.character=character1_instance
	bar1.character_data=character1_instance.character_data
	bar2.character=character2_instance
	bar2.character_data=character2_instance.character_data

func _physics_process(delta: float) -> void:
	if not get_tree().paused:
		custom_time += delta # 将累积的时间赋值给全局着色器参数
		RenderingServer.global_shader_parameter_set("CUSTOM_TIME", custom_time)

## 玩家胜利结算
func game_over_victory(team):
	print("游戏胜利，%s死亡"%[team])
	add_result_scene("成功")

## 玩家胜利结算
func game_over_fail(team):
	print("游戏失败，%s死亡"%[team])
	add_result_scene("失败")

## 添加结算页面
func add_result_scene(result:String):
	if GameState.current_state!=GameState.State.正常:
		return
	var result_instance = result_scene.instantiate()
	result_instance.set_result(result)
	add_child(result_instance)

## 添加暂停页面
func add_pause_scene():
	var pause_instance = pause_scene.instantiate()
	add_child(pause_instance)
