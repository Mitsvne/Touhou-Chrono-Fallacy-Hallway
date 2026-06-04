class_name SkillData
extends Resource

enum SkillType { REGULAR, ULTIMATE } # 技能类型：普通技能、必杀技

@export var skill_id: String = ""
@export var skill_name: String = "未命名技能"
@export var skill_type: SkillType = SkillType.REGULAR
@export var icon: Texture2D
@export_multiline var description: String = "技能描述内容"

# 战斗核心数值
@export var cd: float = 3.0       # 冷却时间
@export var mp_cost: float = 0.0        # 消耗魔力
@export var hits: Array[SkillHitData] = []
