extends BTAction
## 将代理移动到指定位置，优先进行垂直移动。

@export var tolerance := 200.0
@export var timeout_limit := 2.0

var target: CharacterBody2D
var time: float = 0.0

func _enter() -> void:
	target = agent.character_ctrler.get_target()
	time = 0.0

# 每帧由行为树调用的执行函数
func _tick(delta: float) -> Status:
	#print(agent.character_data.direction)
	time += delta
	if time > timeout_limit:
		return SUCCESS
	var target_pos: Vector2 = target.global_position
	if target_pos.distance_to(agent.global_position) < tolerance:
		return SUCCESS
	var speed: float = agent.move_speed
	var dist: float = absf(agent.global_position.y - target_pos.y)
	var dir: Vector2 = agent.global_position.direction_to(target_pos)
	var horizontal_factor: float = remap(dist, 200.0, 500.0, 1.0, 0.0)
	horizontal_factor = clampf(horizontal_factor, 0.0, 1.0)
	dir.x *= horizontal_factor
	var desired_velocity: Vector2 = dir.normalized() * speed
	agent.character_ai_main.move(desired_velocity)
	agent.character_ai_main.update_direction()
	agent.character_ai_main.move_animation()
	return RUNNING
