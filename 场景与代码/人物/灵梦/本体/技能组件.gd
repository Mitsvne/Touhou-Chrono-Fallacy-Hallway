# SkillComponent.gd
extends Node
class_name SkillComponent

# 常量定义，免去写魔法数字（0和1）的痛苦
const SLOT_NORMAL = 0
const SLOT_ULTIMATE = 1

# 运行时真正生效的两个技能资源
var equipped_skills: Array[SkillData] = []
var cooldown_timers: Array[float] = [0.0, 0.0] # 对应两个技能的实时CD

## 核心：由外部（Player）传入角色的 CharacterData 进行初始化
func init_from_data(char_data: CharacterData) -> void:
	equipped_skills.resize(2)
	equipped_skills[SLOT_NORMAL] = char_data.equipped_skill
	equipped_skills[SLOT_ULTIMATE] = char_data.equipped_ultimate
	
	cooldown_timers.fill(0.0)

func _process(delta: float) -> void:
	for i in range(cooldown_timers.size()):
		if cooldown_timers[i] > 0.0:
			cooldown_timers[i] -= delta
			if cooldown_timers[i] <= 0.0:
				cooldown_timers[i] = 0.0

# 检测指定槽位技能是否就绪
func is_skill_ready(slot: int) -> bool:
	if slot < 0 or slot >= cooldown_timers.size() or not equipped_skills[slot]:
		return false
	return cooldown_timers[slot] <= 0.0

# 触发指定槽位的 CD
func start_cooldown(slot: int) -> void:
	if slot >= 0 and slot < equipped_skills.size() and equipped_skills[slot]:
		cooldown_timers[slot] = equipped_skills[slot].cooldown
