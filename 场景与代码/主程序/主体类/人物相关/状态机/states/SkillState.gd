extends CharacterState
## 技能状态 —— 可配置动画名，支持多技能复用
class_name SkillState

## 技能动画名（由 init_states 设置）。为空则自动从 GameData 读取装备技能
@export var skill_animation: String = ""

## 技能数据引用（可选，用于后续伤害/效果扩展）
var skill_data = null


func enter(_prev: CharacterState = null) -> void:
	if not machine or not machine.character_main:
		return
	# 面向目标
	machine.character_main.update_direction()
	# 播放技能动画：优先用自身配置，否则从 GameData 读取装备技能
	var anim = skill_animation if skill_animation != "" else _get_equipped_skill_animation()
	play_animation(anim)


func get_next_state() -> String:
	# 技能动画播放完毕 → 回到常态
	if machine and machine.anplayer and not machine.anplayer.is_playing():
		return "IdleState"
	return ""


func _get_equipped_skill_animation() -> String:
	var deploy_data = GameData.current_deploy_character_data
	if deploy_data and deploy_data.equipped_skill:
		return deploy_data.equipped_skill.skill_id
	return ""
