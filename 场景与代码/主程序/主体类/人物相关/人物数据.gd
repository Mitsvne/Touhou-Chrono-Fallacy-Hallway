extends Node
## 人物数据类：记录人物在局内数据
class_name Character_Data

signal hp_changed
signal mp_changed
signal energy_changed
signal direction_changed

@export var character_name:String="未命名"    #角色名称
var team:String="1P"                 #队伍
var power:float=10                   #攻击力
var move_speed:int=400               #移动速度
var acceleration: float = 1600.0     #加速度（像素/秒²）
var friction: float = 1200.0         #减速度（像素/秒²）
var hp_max:float=200                 #血量上限
var mp_max:float=100                 #魔力值上限
var energy_max:float=100             #耐力上限
var energy_regen:float=10            #耐力恢复速度
var attack_interval:float=0.3        #普攻间隔
var current_skill: SkillData
var current_ultimate: SkillData
var available_skills: Array[SkillData] = []
var available_ultimates: Array[SkillData] = []

@onready var direction:float=1.0:
	set(v):
		if (v==1 or v==-1) and direction!=v:
			direction=v
			direction_changed.emit(direction)
		else:
			return

@onready var hp:float=hp_max:#血量
	set(v):
		v=clampf(v,0.0,hp_max)
		if hp==v:
			return
		hp=v
		hp_changed.emit(hp,hp_max)

@onready var energy:float=energy_max:#耐力
	set(v):
		v=clampf(v,0.0,energy_max)
		if energy==v:
			return
		energy=v
		energy_changed.emit(energy,energy_max)

@onready var mp:float=mp_max:#魔力值
	set(v):
		v=clampf(v,0.0,mp_max)
		if mp==v:
			return
		mp=v
		mp_changed.emit(mp,mp_max)

func _ready() -> void:
	if GameData and GameData.get_character_data(character_name):
		var blueprint = GameData.get_character_data(character_name)
		character_name=blueprint.character_name
		power=blueprint.base_power
		move_speed=blueprint.base_speed
		acceleration=blueprint.base_acceleration
		friction=blueprint.base_friction
		hp_max=blueprint.base_hp
		mp_max=blueprint.base_mp
		energy_max=blueprint.base_energy
		energy_regen=blueprint.base_energy_regen
		attack_interval=blueprint.base_attack_interval
		current_skill=blueprint.equipped_skill
		current_ultimate=blueprint.equipped_ultimate
		available_skills=blueprint.available_skills
		available_ultimates=blueprint.available_ultimates
		if current_skill: print("局内加载技能：", current_skill.skill_name)
		if current_ultimate: print("局内加载必杀：", current_ultimate.skill_name)
		print("Character_Data数据组件：成功同步来自 ", character_name, " 的配置数据！")
	hp = hp_max
	mp = mp_max
	energy = energy_max
	print("1.Character_Data初始化完成")
	pass

func _physics_process(delta: float) -> void:
	energy+=energy_regen*delta #时刻恢复耐力
