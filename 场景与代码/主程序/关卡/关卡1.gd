extends Node

@export var level_id:String
@export var boss_id:String
@export var map:Node2D
@export var result_scene:PackedScene
@export var pause_scene:PackedScene


@onready var _1p_pos: Node2D = $"1P位置"
@onready var _2p_pos: Node2D = $"2P位置"
@onready var camera: Camera2D = $镜头
@onready var arrow: Sprite2D = $ui/箭头
@onready var bar1: Control = $ui/ui血条人物
@onready var bar2: Control = $ui/ui血条boss

var character1:PackedScene
var character2:PackedScene
var character1_path:String
var character2_path:String
var character1_instance:Node2D
var character2_instance:Node2D

var custom_time: float = 0.0        # 存储的时间

func _ready():
	GameState.current_state = GameState.State.正常   # 强制设为正常
	AudioManager.stop_bgm(0)                        # 关bgm
	add_pause_scene()                               # 添加暂停页面并隐藏
	# 添加人物
	var pos1=_1p_pos.global_position
	var pos2=_2p_pos.global_position
	character1_instance=add_character(GameData.get_current_character(),"1P",pos1)
	character2_instance=add_character(boss_id,"2P",pos2)
	character1_instance.character_main.character_is_dead.connect(game_over_fail)
	character2_instance.character_ai_main.character_is_dead.connect(game_over_victory)
	# 相机跟随与地图图层
	camera.reparent(character1_instance)
	camera.position = Vector2.ZERO
	map.z_index = -1
	# 指向箭头与血条
	arrow.player=character1_instance
	arrow.enemy=character2_instance
	bar1.character=character1_instance
	bar1.character_data=character1_instance.character_data
	bar2.character=character2_instance
	bar2.character_data=character2_instance.character_data
	print("main初始化完成")

func _physics_process(delta: float) -> void:
	if not get_tree().paused:
		custom_time += delta # 将累积的时间赋值给全局着色器参数
		RenderingServer.global_shader_parameter_set("CUSTOM_TIME", custom_time)

## 添加角色
func add_character(id:String,team:String="1P",pos:Vector2=Vector2.ZERO):
	var character:PackedScene
	var character_path:String
	var character_instance:Node2D
	character_path=GameData.get_stat(id,"path")
	if character_path != "":
		character = load(character_path)
	else:
		printerr("错误：未找到角色路径")
	character_instance = character.instantiate()
	character_instance.add_to_group(team)
	character_instance.character_data.team=team
	print("%s加入:%s"%[character_instance.character_name,character_instance.character_data.team])
	character_instance.global_position=pos
	add_child(character_instance)
	return character_instance

## 玩家胜利结算
func game_over_victory(team):
	print("游戏胜利，%s死亡"%[team])
	character1_instance.character_ctrler.set_is_allow_losehp(false)
	add_result_scene()

## 玩家失败结算
func game_over_fail(team):
	print("游戏失败，%s死亡"%[team])
	character2_instance.character_ctrler.set_is_allow_losehp(false)
	add_result_scene()

## 添加结算页面
func add_result_scene():
	if GameState.current_state!=GameState.State.正常:
		return
	var result_instance = result_scene.instantiate()
	var current_stars :int = calculate_stars()
	GameData.set_stars(level_id,current_stars)
	GameData.set_current_level_id(level_id)
	add_child(result_instance)

## 计算获得的星级
func calculate_stars() -> int:
	var hp:float=character1_instance.character_data.hp
	var hp_max:float=character1_instance.character_data.hp_max
	print(hp/hp_max)
	if hp/hp_max>=0.9:
		return 3
	elif hp/hp_max>=0.6:
		return 2
	elif hp/hp_max>=0.3:
		return 1
	return 0

## 添加暂停页面
func add_pause_scene():
	var pause_instance = pause_scene.instantiate()
	add_child(pause_instance)
