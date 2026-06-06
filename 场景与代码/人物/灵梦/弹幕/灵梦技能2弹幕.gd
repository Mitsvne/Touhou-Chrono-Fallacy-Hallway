extends Area2D

@export var mp:float=2
@export var audio: AudioStream

@onready var sprite1: Sprite2D = $图形1
@onready var sprite2: Sprite2D = $图形2
@onready var an: AnimationPlayer = $动画
@onready var bullet_data: Bullet_Data = $class/Bullet_Data
@onready var bullet_ctrler: Bullet_Ctrler = $class/Bullet_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready():
	self.area_entered.connect(_on_area_entered)
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	await get_tree().process_frame
	AudioManager.play_sfx(audio,-8)
	effect_ctrler.start_shadow(sprite1,Color(1.0, 1.0, 1.0, 1.0),0.05,0.2)
	effect_ctrler.start_shadow(sprite2,Color(1.0, 1.0, 1.0, 1.0),0.05,0.2)
	bullet_ctrler.start_move_forward(600,-100)
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
		bullet_ctrler.disable_box(hurtbox,true)
		effect_ctrler.stop_shadow()
		an.play(&"hit")
		await an.animation_finished
		queue_free()

func _on_hurtbox_hurt(box: Hitbox, attack_data: AttackData) -> void:
	if box.owner.is_in_group("bullets"):
		bullet_data.hp-=attack_data.damage
		if bullet_data.hp<=0:
			bullet_ctrler.stop_move()
			bullet_ctrler.disable_box(hitbox,true)
			bullet_ctrler.disable_box(hurtbox,true)
			effect_ctrler.stop_shadow()
			an.play(&"hit")
			await an.animation_finished
			queue_free()
