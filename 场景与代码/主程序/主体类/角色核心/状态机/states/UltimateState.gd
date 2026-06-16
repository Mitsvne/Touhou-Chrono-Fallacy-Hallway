extends CharacterState
## 必杀状态 —— 可配置动画名，支持多必杀复用
class_name UltimateState

## 必杀动画名（由 init_states 设置）。为空则自动从 GameData 读取装备必杀
@export var ultimate_animation: String = ""


func enter(_prev: CharacterState = null) -> void:
	if not machine or not machine.character_main:
		return
	# 面向目标
	machine.character_main.update_direction()
	# 播放必杀动画：优先用自身配置，否则从 GameData 读取装备必杀
	var anim = ultimate_animation if ultimate_animation != "" else _get_equipped_ultimate_animation()
	play_animation(anim)


func get_next_state() -> String:
	# 必杀动画播放完毕 → 回到常态
	if machine and machine.anplayer and not machine.anplayer.is_playing():
		return "IdleState"
	return ""


func _get_equipped_ultimate_animation() -> String:
	var deploy_data = GameData.current_deploy_character_data
	if deploy_data and deploy_data.equipped_ultimate:
		return deploy_data.equipped_ultimate.skill_id
	return ""
