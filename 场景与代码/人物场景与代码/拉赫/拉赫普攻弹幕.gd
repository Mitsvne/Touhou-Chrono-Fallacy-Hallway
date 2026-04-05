extends Area2D
var velocity = Vector2.RIGHT * 800 # 初始速度
var ishit=false
var team:String
@onready var an: AnimationPlayer = $动画
@onready var hitarea: CollisionShape2D = $Hitbox/碰撞面
@onready var bullet_ctrler: Bullet_Ctrler = $class/Bullet_Ctrler

func _ready():
	pass

func _physics_process(delta):
	if(not ishit):
		position += velocity * delta
	# 超时删除自身
	await get_tree().create_timer(2).timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(team):
		ishit=true
		hitarea.set_deferred("disabled", true)
		an.play(&"hit")
		await an.animation_finished
		queue_free()
