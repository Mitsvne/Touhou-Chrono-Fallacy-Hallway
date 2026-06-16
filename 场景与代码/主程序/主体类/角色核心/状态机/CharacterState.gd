extends Node
## 角色状态基类 —— 所有具体状态继承此类
class_name CharacterState

## 状态机管理器引用
var machine: CharacterStateMachine = null

## 进入状态时调用
func enter(_prev: CharacterState = null) -> void:
	pass

## 退出状态时调用
func exit(_next: CharacterState = null) -> void:
	pass

## 每物理帧调用
func physics_update(_delta: float) -> void:
	pass

## 返回要切换到的状态名（State 子节点的 name），返回空字符串表示不切换
func get_next_state() -> String:
	return ""

## 受击时修改伤害 —— 子类覆写以实现减伤/反伤等
## 返回修改后的伤害值；默认原样返回
func modify_incoming_damage(_hitbox, _attack_data: AttackData) -> float:
	return _attack_data.damage

## 是否允许自由移动 —— 子类覆写返回 false 阻止移动
func is_movement_allowed() -> bool:
	return true

## 移速倍率 —— 子类覆写实现减速/加速（1.0 = 原速）
func get_move_speed_multiplier() -> float:
	return 1.0

## 便捷方法：在角色 AnimationPlayer 上播放动画
func play_animation(anim_name: String) -> void:
	if not machine or not machine.anplayer:
		return
	if machine.anplayer.has_animation(anim_name):
		machine.anplayer.play(anim_name)
	else:
		printerr("缺失动画: ", anim_name)
