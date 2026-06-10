extends CharacterState
## 防御 —— 正面减伤，每次受击根据伤害消耗耐力
class_name DefenseState

## 正面伤害减免比例（0.5 = 减免50%，只受50%伤害）
@export var damage_reduction: float = 0.5

## 每点伤害消耗的耐力比例
@export var energy_cost_ratio: float = 0.5

## 耐力耗尽后是否强制退出防御
@export var break_on_energy_depleted: bool = true

## 防御期间移速倍率
@export var defense_move_speed: float = 0.4


func enter(_prev: CharacterState = null) -> void:
	play_animation("防御")


func physics_update(_delta: float) -> void:
	# 防御期间维持朝向
	#if machine and machine.character_main:
		#machine.character_main.update_direction()
	pass


func get_next_state() -> String:
	# 松开防御键 → 常态
	if not InputManager.is_action_pressed("defense"):
		return "IdleState"
	return ""


func modify_incoming_damage(hitbox, attack_data: AttackData) -> float:
	var original := attack_data.damage
	if not machine:
		return original

	var character := machine.character
	var data := machine.character_data
	if not character or not data:
		return original

	# 判断是否正面攻击
	var is_front := _is_front_attack(hitbox)
	if not is_front:
		return original  # 背面攻击，不减伤

	# 正面：减伤 + 消耗耐力
	if data.energy <= 0 and break_on_energy_depleted:
		return original  # 耐力耗尽，防御崩溃

	var energy_cost := original * energy_cost_ratio
	data.energy -= energy_cost

	var reduced := original * (1.0 - damage_reduction)
	return max(reduced, 0.0)


func is_movement_allowed() -> bool:
	return true


func get_move_speed_multiplier() -> float:
	return defense_move_speed


func _is_front_attack(hitbox) -> bool:
	var attacker_pos: Vector2 = hitbox.global_position
	var self_pos: Vector2 = machine.character.global_position
	var dir: float = machine.character_data.direction  # 1 = 右, -1 = 左

	# 攻击者在角色面朝方向 → 正面
	return (attacker_pos.x - self_pos.x) * dir > 0
