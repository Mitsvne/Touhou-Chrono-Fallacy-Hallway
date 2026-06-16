extends CharacterState
## 死亡 —— 人物死亡后的终态
class_name DeadState


func enter(_prev: CharacterState = null) -> void:
	if not machine or not machine.character_main:
		return

	var main = machine.character_main
	var ctrl = machine.character_ctrler
	var data = machine.character_data

	# 设置无敌和重力
	ctrl.set_invincible(true)
	ctrl.apply_gravity(true)
	main.is_alive = false

	# 播放死亡动画
	play_animation("死亡")

	# 发射角色死亡事件
	EventBus.character_dead.emit(data.team)


func get_next_state() -> String:
	# 死亡是终态，永不自行切换
	return ""
