extends Area2D

@export var Sprite: AnimatedSprite2D
@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var effect_ctrler: Effect_Ctrler
@export var bullet_ctrler: Bullet_Ctrler

var ishit=false
var team:String
var color:int

func _ready():
	await get_tree().process_frame #等一帧，其他类初始完成
	randomize()
	var num = randi_range(1, 3)
	color=num
	if num==1:
		an.play(&"loop_red")
	elif num==2:
		an.play(&"loop_blue")
	else:
		an.play(&"loop_green")
	#print(bullet_ctrler.get_Target())

func _process(_delta):
	if(ishit):
		pass
	else:
		pass


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(team):
		ishit=true
		hitarea.set_deferred("disabled", true)
		if color==1:
			an.play(&"hit_red")
		elif color==2:
			an.play(&"hit_blue")
		else:
			an.play(&"hit_green")
		await an.animation_finished
		queue_free()
