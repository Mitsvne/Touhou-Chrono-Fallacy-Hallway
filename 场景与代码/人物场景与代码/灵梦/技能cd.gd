extends HBoxContainer
@onready var cd_label: Label = $Label
@onready var skill1_cd: Timer = $"../../计时器/技能1cd"

var cooldown_total = 1         # 总冷却时间（秒）
var cooldown_remaining = 0     # 剩余冷却时间

func _process(_delta):
	if not skill1_cd.is_stopped():
		cooldown_total = skill1_cd.wait_time
		cooldown_remaining = skill1_cd.time_left
		if cooldown_remaining > 0:
			cd_label.text = "CD:"+str(snapped(cooldown_remaining, 0.1)) + "s"
	else:
		cd_label.text = "CD:Ready"
