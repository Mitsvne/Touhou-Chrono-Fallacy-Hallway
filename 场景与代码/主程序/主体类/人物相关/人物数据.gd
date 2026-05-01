extends Node
## 人物数据类：记录基础数据
class_name Character_Data

signal hp_changed
signal mp_changed
signal energy_changed
signal direction_changed


@onready var team:String
@onready var direction:float=1.0:
	set(v):
		if (v==1 or v==-1) and direction!=v:
			direction=v
			direction_changed.emit(direction)
		else:
			#push_warning("direction 只能赋值为 1 或 -1，当前值不变")
			return

@export var hp_max:float=200#血量上限
@onready var hp:float=hp_max:#血量
	set(v):
		v=clampf(v,0.0,hp_max)
		if hp==v:
			return
		hp=v
		hp_changed.emit(hp,hp_max)

@export var energy_max:float=100#耐力上限
@export var energy_regen:float=10#耐力恢复速度
@onready var energy:float=energy_max:#耐力
	set(v):
		v=clampf(v,0.0,energy_max)
		if energy==v:
			return
		energy=v
		energy_changed.emit(energy,energy_max)

@export var mp_max:float=100#魔力值上限
@onready var mp:float=mp_max:#魔力值
	set(v):
		v=clampf(v,0.0,mp_max)
		if mp==v:
			return
		mp=v
		mp_changed.emit(mp,mp_max)

func _ready() -> void:
	if team=="1P":
		direction=1.0
	else:
		direction=-1.0
	print("1.Character_Data初始化完成")
	pass

func _physics_process(delta: float) -> void:
	energy+=energy_regen*delta #时刻恢复耐力
	
