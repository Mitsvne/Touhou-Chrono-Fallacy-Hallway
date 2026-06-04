extends Area2D
class_name Hitbox

signal hit(hurtbox)

@export var attack_data: AttackData
@export var hit_index: int = 0
var team: String
var hurtboxes: Array[Hurtbox] = []
var _cooldown_timers: Dictionary = {}

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	set_process(true)

func _physics_process(delta: float):
	for hurtbox in hurtboxes:
		if not is_instance_valid(hurtbox):
			continue
		var cooldown_accum = _cooldown_timers.get(hurtbox, 0.0)
		cooldown_accum += delta
		if cooldown_accum >= attack_data.attack_interval:
			emit_hit(hurtbox)
			cooldown_accum -= attack_data.attack_interval
		_cooldown_timers[hurtbox] = cooldown_accum

func _on_area_entered(area: Area2D):
	if owner.is_in_group("bullets"):
		team = owner.bullet_data.team
	if owner.is_in_group("props"):
		team = owner.prop_data.team
	if owner.is_in_group("characters"):
		team = owner.character_data.team
	if area is Hurtbox and not area.owner.is_in_group(team):
		if not hurtboxes.has(area):
			hurtboxes.append(area)
			_cooldown_timers[area] = attack_data.attack_interval

func _on_area_exited(area: Area2D):
	if area is Hurtbox:
		var id = hurtboxes.find(area)
		if id != -1:
			hurtboxes.remove_at(id)
		_cooldown_timers.erase(area)

func emit_hit(hurtbox: Hurtbox):
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self, attack_data)
