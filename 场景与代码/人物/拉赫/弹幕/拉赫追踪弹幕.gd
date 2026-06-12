extends Area2D

@export var mp:float=5
@export var audio: AudioStream

@onready var an: AnimationPlayer = $动画
@onready var bullet_data: Bullet_Data = $class/Bullet_Data
@onready var bullet_ctrler: Bullet_Ctrler = $class/Bullet_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler
@onready var hitbox: Hitbox = $Hitbox

func _ready():
	self.area_entered.connect(_on_area_entered)
	await get_tree().process_frame
	AudioManager.play_sfx(audio)
	var random_y: float = randf_range(-400, 400)
	bullet_ctrler.start_move(Vector2(400,random_y),Vector2(-50,0))
	await get_tree().create_timer(0.1, false).timeout
	bullet_ctrler.start_track(bullet_ctrler.get_target(),600,0,400)
	await get_tree().create_timer(3, false).timeout
	bullet_ctrler.stop_track()
	await get_tree().create_timer(3, false).timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.team) and area.owner.is_in_group("characters"):
		bullet_data.bullet_owner.character_data.mp+=mp
		bullet_ctrler.stop_move()
		bullet_ctrler.disable_box(hitbox,true)
		an.play(&"hit")
		await an.animation_finished
		queue_free()
