extends Area2D
class_name Hitbox

signal hit(hurtbox)

@export var attack_data: AttackData
var team: String
var hurtboxes: Array[Hurtbox] = []
var _last_trigger_time: Dictionary = {}

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	set_process(true)

func _physics_process(_delta: float):
	var now = Time.get_ticks_msec() / 1000.0
	for hurtbox in hurtboxes:
		if not is_instance_valid(hurtbox):
				continue
		var last_time = _last_trigger_time.get(hurtbox, 0.0)
		if now - last_time >= attack_data.attack_interval:
				_last_trigger_time[hurtbox] = now
				emit_hit(hurtbox)

func _on_area_entered(area: Area2D):
	team=owner.bullet_data.bullet_team 
	if area is Hurtbox and not area.owner.is_in_group(team):
		
		if not hurtboxes.has(area):
			hurtboxes.append(area)

func _on_area_exited(area: Area2D):
	if area is Hurtbox:
		var id = hurtboxes.find(area)
		if id != -1:
			hurtboxes.remove_at(id)

func emit_hit(hurtbox: Hurtbox):
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self, attack_data)
