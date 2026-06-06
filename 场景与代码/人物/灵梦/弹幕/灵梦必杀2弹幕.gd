extends Area2D

@onready var an: AnimationPlayer = $动画
@onready var bullet_data: Bullet_Data = $class/Bullet_Data
@onready var bullet_ctrler: Bullet_Ctrler = $class/Bullet_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler
@onready var hitbox: Hitbox = $Hitbox
@onready var hitbox2: Hitbox = $Hitbox2

func _ready():
	await get_tree().process_frame
	await an.animation_finished
	queue_free()

func init_damage():
	hitbox.attack_data.damage=_calculate_damage(hitbox)
	hitbox2.attack_data.damage=_calculate_damage(hitbox2)

func _calculate_damage(box:Hitbox):
	var final_damage:float
	if bullet_data.skill_hits:
		var hits_array = bullet_data.skill_hits
		var current_hit_data: SkillHitData = hits_array[box.hit_index]
		final_damage=bullet_data.power*current_hit_data.damage_multiplier
	elif box.attack_data.damage_multiplier!=0:
		final_damage=bullet_data.power*box.attack_data.damage_multiplier
	else:
		final_damage=box.attack_data.damage
	return final_damage
