extends Area2D

@export var add_audio: AudioStream
@export var hit_audio: AudioStream

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
	AudioManager.play_sfx(add_audio,-6)
	var target=bullet_ctrler.get_target().global_position
	bullet_ctrler.start_move_parabola(target,0,150,0)
	await get_tree().create_timer(4, false).timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.team) and area.owner.is_in_group("characters"):
		effect_ctrler.shake_once(Vector2(2,2))
		bullet_data.bullet_owner.character_data.mp+=10
		bullet_ctrler.stop_move()
		bullet_ctrler.disable_box(hitbox,true)
		bullet_ctrler.disable_box(hurtbox,true)
		an.play(&"hit")
		AudioManager.play_sfx(hit_audio)
		await an.animation_finished
		queue_free()


func _on_hurtbox_hurt(box: Hitbox, attack_data: AttackData) -> void:
	if box.owner.is_in_group("bullets"):
		bullet_data.hp-=attack_data.damage
		if bullet_data.hp<=0:
			bullet_ctrler.stop_move()
			bullet_ctrler.disable_box(hitbox,true)
			bullet_ctrler.disable_box(hurtbox,true)
			an.play(&"hit")
			AudioManager.play_sfx(hit_audio)
			await an.animation_finished
			queue_free()
