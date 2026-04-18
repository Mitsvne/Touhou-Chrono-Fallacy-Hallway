extends Area2D
class_name Hitbox

signal hit(hurtbox)

@export var attack_data: AttackData
var team: String
var hurtboxes: Array[Hurtbox] = []
var _cooldown_timers: Dictionary = {}

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	set_process(true)

func _physics_process(delta: float):
	# 如果没有时间缩放，这里可以直接操作
	for hurtbox in hurtboxes:
		if not is_instance_valid(hurtbox):
			continue
		# 获取或初始化该 Hurtbox 的累积时间
		var cooldown_accum = _cooldown_timers.get(hurtbox, 0.0)
		cooldown_accum += delta
		if cooldown_accum >= attack_data.attack_interval:
			# 触发攻击
			emit_hit(hurtbox)
			# 减去间隔时间，保留超出部分（避免误差积累）
			cooldown_accum -= attack_data.attack_interval
		_cooldown_timers[hurtbox] = cooldown_accum

func _on_area_entered(area: Area2D):
	team = owner.bullet_data.bullet_team
	if area is Hurtbox and not area.owner.is_in_group(team):
		if not hurtboxes.has(area):
			hurtboxes.append(area)
			_cooldown_timers[area] = attack_data.attack_interval  # 设满值使其立即触发

func _on_area_exited(area: Area2D):
	if area is Hurtbox:
		var id = hurtboxes.find(area)
		if id != -1:
			hurtboxes.remove_at(id)
		_cooldown_timers.erase(area)

func emit_hit(hurtbox: Hurtbox):
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self, attack_data)
