extends Control

@onready var icon_rect: TextureRect = $图标
@onready var cd_progress: TextureProgressBar = $进度条
@onready var cd_label: Label = $cd

var data_component: Character_Data = null
var is_ultimate_slot: bool = false # 区分是普通技能槽还是大招槽

## UI 初始化
func setup(char_data: Character_Data, is_ult: bool = false) -> void:
	data_component = char_data
	is_ultimate_slot = is_ult
	# 根据槽位类型读取对应的技能静态数据
	var skill: SkillData = data_component.current_ultimate if is_ultimate_slot else data_component.current_skill
	if skill:
		icon_rect.texture = skill.icon
		cd_progress.value = 0
		cd_label.text = ""
	else:
		hide() # 如果该角色没有装备这个技能，直接隐藏图标槽位

func _process(_delta: float) -> void:
	if not data_component:
		return
	# 1. 根据身份获取对应的 剩余CD时间 和 技能总时间
	var remaining: float = data_component.ultimate_cd_timer if is_ultimate_slot else data_component.skill_cd_timer
	var skill_resource: SkillData = data_component.current_ultimate if is_ultimate_slot else data_component.current_skill
	if not skill_resource: 
		return
	var total: float = skill_resource.cd
	# 2. 刷新 UI 表现
	if remaining > 0.0:
		cd_progress.show()
		cd_label.show()
		# 填入百分比遮罩
		cd_progress.value = (remaining / total) * 100
		# 倒计时文本格式化
		if remaining >= 1.0:
			cd_label.text = "%d" % ceil(remaining)
		else:
			cd_label.text = "%.1f" % remaining
	else:
		cd_progress.hide()
		cd_label.hide()
