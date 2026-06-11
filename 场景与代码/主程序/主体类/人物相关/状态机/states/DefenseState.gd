extends CharacterState
## 防御 —— 正面减伤，每次受击根据伤害消耗耐力
class_name DefenseState

## 正面伤害减免比例
@export var damage_reduction: float = 0.8

## 每点伤害消耗的耐力比例
@export var energy_cost_ratio: float = 1.5

## 耐力耗尽后是否强制退出防御
@export var break_on_energy_depleted: bool = true

## 防御期间移速倍率
@export var defense_move_speed: float = 0.4

@export var defense_effect: Node2D
@export var hurbox_shape2: CollisionShape2D
func enter(_prev: CharacterState = null) -> void:
	play_animation("防御")
	defense_effect.fade_in(0.3)
	hurbox_shape2.disabled=false
	# 防御期间暂停耐力恢复
	if machine and machine.character_data:
		machine.character_data.energy_regen_locked = true


func exit(_next: CharacterState = null) -> void:
	defense_effect.fade_out(0.3)
	hurbox_shape2.disabled=true
	# 退出防御时恢复耐力恢复
	if machine and machine.character_data:
		machine.character_data.energy_regen_locked = false
	pass

func physics_update(_delta: float) -> void:
	# 防御期间维持朝向
	#if machine and machine.character_main:
		#machine.character_main.update_direction()
	pass


func get_next_state() -> String:
	# 松开防御键 → 常态
	if not InputManager.is_action_pressed("defense"):
		return "IdleState"
	# 防御崩溃后强制退出
	if machine and machine.character_data and machine.character_data.defense_broken:
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
		data.defense_broken = true
		return original  # 耐力耗尽，防御崩溃

	var energy_cost := original * energy_cost_ratio
	data.energy -= energy_cost

	# 此击耗尽耐力，触发防御崩溃
	if data.energy <= 0 and break_on_energy_depleted:
		data.defense_broken = true
		data.just_broke_guard = true  # 标记本帧破防，供受击处理读取

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
