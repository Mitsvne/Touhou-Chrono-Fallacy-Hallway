extends Node
## 人物数据类：记录人物在局内数据
class_name Character_Data

signal hp_changed
signal mp_changed
signal energy_changed
signal direction_changed
signal skill_ready
signal ultimate_ready

@export var character_name:String="未命名"    #角色名称
var team:String="1P"                 #队伍
var defense_broken: bool = false       #防御崩溃后需耐力恢复至60%才能重新防御
var energy_regen_locked: bool = false  #防御期间暂停耐力恢复
var just_broke_guard: bool = false     #本帧刚破防，用于标记破防攻击的attack_type
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
var skill_cd_timer: float = 0.0
var ultimate_cd_timer: float = 0.0
var active_effects: Array[CardEffect] = []

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
		print(hp)
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
		if blueprint.equipped_skill:
			# 1. 复制外层技能数据
			current_skill = blueprint.equipped_skill.duplicate(false)
			# 2. 手动强行深拷贝内置的 Array[SkillHitData] 数组，破解 Godot 引擎 Bug
			var unique_hits: Array[SkillHitData] = []
			for hit in blueprint.equipped_skill.hits:
				if hit:
					unique_hits.append(hit.duplicate(true))
			current_skill.hits = unique_hits # 重新挂载独一无二的伤害数据
		else:
			current_skill = null
		if blueprint.equipped_ultimate:
			current_ultimate = blueprint.equipped_ultimate.duplicate(false)
			var unique_ult_hits: Array[SkillHitData] = []
			for hit in blueprint.equipped_ultimate.hits:
				if hit:
					unique_ult_hits.append(hit.duplicate(true))
			current_ultimate.hits = unique_ult_hits
		else:
			current_ultimate = null
		if current_skill: print("局内加载技能：", current_skill.skill_name)
		if current_ultimate: print("局内加载必杀：", current_ultimate.skill_name)
		print("Character_Data数据组件：成功同步来自 ", character_name, " 的配置数据！")
	skill_cd_timer = 0.0
	ultimate_cd_timer = 0.0
	hp = hp_max
	mp = mp_max
	energy = energy_max
	if owner.is_in_group("players"):
		_initialize_card_effects()
	print("1.Character_Data初始化完成")
	pass

func _physics_process(delta: float) -> void:
	if not energy_regen_locked:
		energy+=energy_regen*delta #时刻恢复耐力（防御期间暂停）
	if defense_broken and energy >= energy_max * 0.6:
		defense_broken = false  # 耐力恢复至60%，允许重新进入防御
	if skill_cd_timer > 0.0:
		skill_cd_timer = maxf(skill_cd_timer - delta, 0.0)
		if skill_cd_timer == 0.0:
			skill_ready.emit()
	if ultimate_cd_timer > 0.0:
		ultimate_cd_timer = maxf(ultimate_cd_timer - delta, 0.0)
		if ultimate_cd_timer == 0.0:
			ultimate_ready.emit()

## 1. 注入并激活属于该角色的所有卡牌
func _initialize_card_effects() -> void:
	if GameData == null or GameData.current_character_data == null:
		return
	var char_data = GameData.current_character_data
	# 遍历人物身上的所有装备卡
	for card in char_data.equipped_cards:
		if card == null: continue
		for effect in card.effects:
			if effect == null: continue
			var runtime_effect = effect.duplicate() as CardEffect
			active_effects.append(runtime_effect)
			# 立即触发被动钩子
			if owner is CharacterBody2D:
				runtime_effect.apply_passive(owner)

## 检测普通技能是否可用（有技能且 CD 为 0）
func is_skill_ready() -> bool:
	return current_skill != null and skill_cd_timer <= 0.0

## 检测必杀技是否可用
func is_ultimate_ready() -> bool:
	return current_ultimate != null and ultimate_cd_timer <= 0.0

## 触发普通技能 CD
func start_skill_cooldown() -> void:
	if current_skill:
		skill_cd_timer = current_skill.cd

## 触发必杀技 CD
func start_ultimate_cooldown() -> void:
	if current_ultimate:
		ultimate_cd_timer = current_ultimate.cd
