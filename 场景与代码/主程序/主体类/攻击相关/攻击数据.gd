extends Resource
class_name AttackData



@export var name: String = "hit"             # 攻击面名字
@export var damage: float = 10.0             # 攻击伤害
@export var damage_multiplier: float = 0.0   # 伤害倍率
@export var attack_type: int = 1             # 攻击类型，用于特殊逻辑
@export var attack_interval: float = 1       # 攻击间隔
@export var hitstop: float = 0.0             # 攻击停顿
