extends Area2D

@export var mp:float=5

@onready var sprite: Sprite2D = $图片
@onready var particle: GPUParticles2D = $粒子
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
	bullet_ctrler.start_move_forward(200,-100)
	await get_tree().create_timer(3, false).timeout
	particle.emitting=false
	await get_tree().create_timer(1, false).timeout
	queue_free()

## 命中效果
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.team) and area.owner.is_in_group("characters"):
		bullet_data.bullet_owner.character_data.mp+=mp

## 被攻击命中效果
func _on_hurtbox_hurt(box: Hitbox, attack_data: AttackData) -> void:
	if box.owner.is_in_group("bullets"):
		bullet_data.hp-=attack_data.damage
		if bullet_data.hp<=0:
			bullet_ctrler.stop_move()
			bullet_ctrler.disable_box(hitbox,true)
			bullet_ctrler.disable_box(hurtbox,true)
			an.play("hit")
			await an.animation_finished
			queue_free()
