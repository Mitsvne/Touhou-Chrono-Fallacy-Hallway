extends Area2D
class_name Hitbox
signal hit(hurtbox)
@export var attack_data: AttackData
var team:String
func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	team=owner.team
	if area is Hurtbox and not area.owner.is_in_group(team):
		#print("自身 %s" % [self])
		#print("[hit] %s => %s [attack_damage] %s" % [owner.name, area.owner.name,attack_data.damage])
		hit.emit(area)
		area.hurt.emit(self, attack_data)
