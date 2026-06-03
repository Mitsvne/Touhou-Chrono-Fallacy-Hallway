extends Area2D

@export var speed:float=400
@export var drag:float=0
@export var mp:float=5
@export var audio: AudioStream

@onready var an: AnimationPlayer = $动画
@onready var bullet_data: Bullet_Data = $class/Bullet_Data
@onready var bullet_ctrler: Bullet_Ctrler = $class/Bullet_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox

var hit_audio = preload("res://素材/人物素材/灵梦/音效/阴阳玉爆炸.wav")
var add_audio = preload("res://素材/人物素材/灵梦/音效/弹幕发射2.wav")

func _ready():
	self.area_entered.connect(_on_area_entered)
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	await get_tree().process_frame
	bullet_ctrler.start_move_forward(speed,drag)
	await get_tree().create_timer(2, false).timeout
	queue_free()

func _physics_process(_delta):
	#不要直接删除
	pass

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.team) and area.owner.is_in_group("characters"):
		bullet_data.bullet_owner.character_data.mp+=mp
		bullet_ctrler.stop_move()
		bullet_ctrler.disable_box(hitbox,true)
		bullet_ctrler.disable_box(hurtbox,true)
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
			an.play(&"hit")
			await an.animation_finished
			queue_free()
