extends Node

@export var level_id:String
@export var boss_id: String
@export var map:Node2D
@export var result_scene:PackedScene
@export var pause_scene:PackedScene


@onready var _1p_pos: Node2D = $"1P位置"
@onready var _2p_pos: Node2D = $"2P位置"
@onready var camera: Camera2D = $镜头
@onready var arrow: Sprite2D = $ui/箭头
@onready var bar1: Control = $ui/ui血条人物
@onready var bar2: Control = $ui/ui血条boss
@onready var skill_slot: Control = $ui/cd显示容器/技能cd显示
@onready var ultimate_slot: Control = $ui/cd显示容器/必杀cd显示
@onready var cd_box: HBoxContainer = $ui/cd显示容器


var character1:PackedScene
var character2:PackedScene
var character1_path:String
var character2_path:String
var character1_instance:Node2D
var character2_instance:Node2D
var custom_time: float = 0.0        # 存储的时间

func _ready():
	# 进入开场状态（开场结束后自动切为正常）
	EventBus.opening_started.connect(_on_opening_started)
	# 状态切换由 切换状态 在淡入后自动执行，此处仅连接信号
	AudioManager.stop_bgm(0)                        # 关bgm
	# 添加人物
	var pos1=_1p_pos.global_position
	var pos2=_2p_pos.global_position
	var player_path=GameData.current_deploy_character_data.character_scene_path
	var boss_path=GameData.get_character_data(boss_id).character_scene_path
	character1_instance=add_character(player_path,"1P",pos1)
	character2_instance=add_character(boss_path,"2P",pos2)
	# 相机跟随与地图图层
	camera.reparent(character1_instance)
	camera.position = Vector2.ZERO
	map.z_index = -1
	# 指向箭头与血条
	arrow.player=character1_instance
	arrow.enemy=character2_instance
	bar1.character_data=character1_instance.character_data
	bar2.character_data=character2_instance.character_data
	skill_slot.setup(character1_instance.character_data,false)
	ultimate_slot.setup(character1_instance.character_data,true)
	# 角色死亡信号连接
	EventBus.character_dead.connect(game_over)
	print("main初始化完成")

## 开场开始回调 —— 在此驱动入场动画、对话等，完成后调用 end_opening()
func _on_opening_started() -> void:
	# TODO: 替换为实际的入场动画/对话逻辑
	# 示例：等待2秒后结束开场
	print("关卡1：开场序列开始")
	await get_tree().create_timer(0.5, false).timeout
	# 通过状态管理器结束开场
	if GameStateManager.states.has("开场"):
		GameStateManager.states["开场"].end_opening()


func _physics_process(delta: float) -> void:
	if not get_tree().paused:
		custom_time += delta # 将累积的时间赋值给全局着色器参数
		RenderingServer.global_shader_parameter_set("CUSTOM_TIME", custom_time)

## 添加角色
func add_character(path:String,team:String="1P",pos:Vector2=Vector2.ZERO):
	var character:PackedScene
	var character_instance:Node2D
	if path != "":
		character = load(path)
	else:
		push_error("加载失败：角色资源中未配置场景路径！")
		return
	character_instance = character.instantiate()
	character_instance.add_to_group(team)
	character_instance.character_data.team=team
	print("%s加入:%s"%[character_instance.character_name,character_instance.character_data.team])
	character_instance.global_position=pos
	add_child(character_instance)
	return character_instance

## 游戏结束，进入结算
func game_over(team):
	character1_instance.character_ctrler.set_is_allow_losehp(false)
	character2_instance.character_ctrler.set_is_allow_losehp(false)
	if team=="1P":
		print("信号游戏失败，%s死亡"%[team])
	else:
		print("信号游戏胜利，%s死亡"%[team])
	var current_stars :int = calculate_stars()
	GameStateManager.change_state("结算")
	EventBus.level_complete.emit(level_id,current_stars)
	GameData.set_stars(level_id,current_stars)

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
