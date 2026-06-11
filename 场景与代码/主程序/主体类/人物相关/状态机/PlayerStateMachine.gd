extends CharacterStateMachine
## 玩家状态机 —— 仅在"无编辑器放置状态"时作为兜底创建默认状态集
class_name PlayerStateMachine


## 兜底：编辑器中没有放置任何状态时，自动创建默认玩家状态集
func init_states() -> void:
	_register_state("IdleState", IdleState.new())
	_register_state("MoveState", MoveState.new())
	_register_state("DashState", DashState.new())
	# 技能状态 —— 不设 skill_animation，自动从 GameData 读取装备技能
	_register_state("SkillState", SkillState.new())
	# 必杀状态 —— 不设 ultimate_animation，自动从 GameData 读取装备必杀
	_register_state("UltimateState", UltimateState.new())
	_register_state("DefenseState", DefenseState.new())
	_register_state("DeadState", DeadState.new())


## 玩家输入检测
func check_special_inputs() -> String:
	if not character_main or not character_main.has_method("fire_bullet"):
		return ""
	var cd: Character_Data = character_data
	# 防御
	if InputManager.is_action_just_pressed("defense"):
		if cd.defense_broken and cd.energy < cd.energy_max * 0.6:
			return ""  # 防御崩溃后耐力不足60%，禁止进入防御
		return "DefenseState"

	# 技能
	if InputManager.is_action_just_pressed("skill") and cd.is_skill_ready():
		cd.start_skill_cooldown()
		return "SkillState"
	# 必杀
	var mp_cost: float = cd.current_ultimate.mp_cost
	if InputManager.is_action_just_pressed("ultimate") and cd.mp >= mp_cost and cd.is_ultimate_ready():
		cd.mp -= mp_cost
		cd.start_ultimate_cooldown()
		return "UltimateState"
	# 冲刺
	if InputManager.is_action_just_pressed("dash") and cd.energy >= 25:
		cd.energy -= 25
		return "DashState"
	return ""
