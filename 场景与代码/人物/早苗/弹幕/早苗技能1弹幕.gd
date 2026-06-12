extends Area2D

@export var mp:float=2
@export var audio: AudioStream
@export var audio2: AudioStream
@onready var an: AnimationPlayer = $动画
@onready var bullet_data: Bullet_Data = $class/Bullet_Data
@onready var bullet_ctrler: Bullet_Ctrler = $class/Bullet_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler
@onready var hitbox: Hitbox = $Hitbox

func _ready():
	self.area_entered.connect(_on_area_entered)
	await get_tree().process_frame
	AudioManager.play_sfx(audio,-5)
	an.play("start")
	await an.animation_finished
	AudioManager.play_sfx(audio2,-8)
	an.play("loop")
	var target=bullet_ctrler.get_target().global_position
	bullet_ctrler.start_move_towards(target,600,-10, 10, 60)
	await get_tree().create_timer(2, false).timeout
	queue_free()

func init_damage():
	var final_damage:float
	if bullet_data.skill_hits:
		var hits_array = bullet_data.skill_hits
		var current_hit_data: SkillHitData = hits_array[hitbox.hit_index]
		final_damage=bullet_data.power*current_hit_data.damage_multiplier
	elif hitbox.attack_data.damage_multiplier!=0:
		final_damage=bullet_data.power*hitbox.attack_data.damage_multiplier
	else:
		final_damage=hitbox.attack_data.damage
	hitbox.attack_data.damage=final_damage

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.team) and area.owner.is_in_group("characters"):
		bullet_data.bullet_owner.character_data.mp+=mp
		bullet_ctrler.stop_move()
		bullet_ctrler.disable_box(hitbox,true)
		an.play(&"hit")
		await an.animation_finished
		queue_free()
