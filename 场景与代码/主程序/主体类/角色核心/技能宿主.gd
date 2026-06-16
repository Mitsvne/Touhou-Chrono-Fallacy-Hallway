extends Node
## 技能宿主 —— 管理 SkillNode 子节点，负责注入引用、执行、打断
class_name SkillHost

## 当前正在执行的技能
var current_skill: SkillNode = null

var agent: CharacterBody2D
var character_data: Character_Data
var character_ctrler: Character_Ctrler
var effect_ctrler: Effect_Ctrler

var _skills: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is SkillNode:
			_skills[child.name] = child


## 注入上下文
func setup(p_agent: CharacterBody2D, p_data: Character_Data, p_ctrler: Character_Ctrler, p_effect: Effect_Ctrler, p_anplayer: AnimationPlayer) -> void:
	agent = p_agent
	character_data = p_data
	character_ctrler = p_ctrler
	effect_ctrler = p_effect
	for skill in _skills.values():
		skill.agent = agent
		skill.character_data = character_data
		skill.character_ctrler = character_ctrler
		skill.effect_ctrler = effect_ctrler
		skill.anplayer = p_anplayer


## 按技能名执行
func execute(skill_name: String) -> bool:
	var skill = _get_skill(skill_name)
	if not skill:
		return false
	return _run(skill)


## 直接执行 SkillNode 引用（FSM 用）
func execute_node(skill: SkillNode) -> bool:
	if not skill:
		return false
	return _run(skill)


## 中断当前技能
func abort() -> void:
	if not current_skill:
		return
	current_skill.abort()
	current_skill = null


func _run(skill: SkillNode) -> bool:
	if current_skill and not current_skill.interruptible:
		return false
	if current_skill:
		abort()

	current_skill = skill

	# 连接信号
	if skill.finished.is_connected(_on_skill_finished):
		skill.finished.disconnect(_on_skill_finished)
	if skill.interrupted.is_connected(_on_skill_interrupted):
		skill.interrupted.disconnect(_on_skill_interrupted)
	skill.finished.connect(_on_skill_finished, CONNECT_ONE_SHOT)
	skill.interrupted.connect(_on_skill_interrupted, CONNECT_ONE_SHOT)

	_await_skill(skill)
	return true


func _await_skill(skill: SkillNode) -> void:
	# 技能自行管动画和弹幕时机，宿主只等 finished
	skill.execute()
	await skill.finished


func _on_skill_finished() -> void:
	current_skill = null


func _on_skill_interrupted() -> void:
	current_skill = null


func _get_skill(skill_name: String) -> SkillNode:
	if _skills.has(skill_name):
		return _skills[skill_name]
	for key in _skills:
		if key.to_lower() == skill_name.to_lower():
			return _skills[key]
	return null
