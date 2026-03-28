extends Resource
class_name AttackData

@export var name: String = "hit"
@export var damage: float = 10.0
@export var knockback_xy: Vector2 = Vector2(0,0)      # 击退xy模式
@export var knockback_force: float = 200.0      # 击退力度
@export var knockback_angle: float = 0.0         # 击退角度（弧度），0表示向右
@export var attack_type: int = 1       # 攻击类型，用于特殊逻辑
