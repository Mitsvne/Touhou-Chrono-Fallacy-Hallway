extends Area2D

# 速度（像素/秒）
var velocity: Vector2 = Vector2.ZERO
# 追踪目标（节点或固定位置）
var target_node: Node2D = null
var target_position: Vector2 = Vector2.ZERO
# 转向速率（弧度/秒），值越大转向越快
var turn_rate: float = 2.0
# 是否追踪移动目标（若为 true 且 target_node 存在，每帧更新目标位置）
var track_moving_target: bool = true
@onready var sprite: AnimatedSprite2D = $素材库
@onready var an: AnimationPlayer = $动画
@onready var hitarea: CollisionShape2D = $Hitbox/碰撞面
@export var bullet_ctrler: Bullet_Ctrler

var ishit=false
var team:String
var color:int


func _ready():
	randomize()
	var num = randi_range(1, 3)
	color=num
	if num==1:
		an.play(&"loop_red")
	elif num==2:
		an.play(&"loop_blue")
	else:
		an.play(&"loop_green")
	launch(Vector2(300,0),Vector2(380,200))

func _process(delta):
	if(not ishit):
		# 更新目标位置（如果追踪移动目标）
		if track_moving_target and target_node != null:
			target_position = target_node.global_position
		# 转向逻辑
		if velocity.length() > 0:
			var to_target = target_position - global_position
			if to_target.length() > 0:
				var target_dir = to_target.normalized()
				var current_dir = velocity.normalized()
				var angle_diff = current_dir.angle_to(target_dir)
				var max_turn = turn_rate * delta
				var turn = clamp(angle_diff, -max_turn, max_turn)
				velocity = velocity.rotated(turn)
		# 移动
		position += velocity * delta

# 发射参数：起始位置、起始速度矢量、目标（节点或固定位置）
func launch(start_vel: Vector2, target_pos: Vector2 = Vector2.ZERO, target = null):
	velocity = start_vel
	if target is CharacterBody2D:
		target_node = target
		target_position = target.global_position
		#print(target_node)
		track_moving_target = true
	else:
		#print(target_position)
		target_position = target_pos
		track_moving_target = false


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
