extends Area2D
# 速度（像素/秒）
var velocity: Vector2 = Vector2.ZERO
# 重力加速度（像素/秒²），正值表示向下
var bullet_gravity: float = 800.0
var ishit=false
var team:String
@onready var Sprite: AnimatedSprite2D = $素材库
@onready var an: AnimationPlayer = $动画
@onready var audio: AudioStreamPlayer = $命中音效
@onready var hitarea: CollisionShape2D = $Hitbox/碰撞面
@onready var effect_ctrler: Effect_Ctrler = $Effect_Ctrler

func _ready():
	launch_with_angle(velocity,200,500)
	effect_ctrler.start_shadow(Sprite)

func _process(delta: float) -> void:
	if(not ishit):
		an.play(&"loop")
		# 应用重力影响速度
		velocity.y += bullet_gravity * delta
		# 更新位置
		position += velocity * delta
	# 超时删除自身
	await get_tree().create_timer(2).timeout
	effect_ctrler.stop_shadow()
	queue_free()

# 另一种发射方式：角度（弧度）和初速度
func launch_with_angle(start_pos: Vector2, angle: float, speed: float) -> void:
	global_position = start_pos
	velocity = Vector2(cos(angle) * speed, sin(angle) * speed)



func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(team):
		ishit=true
		hitarea.set_deferred("disabled", true)
		an.play(&"hit")
		audio.play()
		effect_ctrler.stop_shadow()
		await an.animation_finished
		await audio.finished
		queue_free()
