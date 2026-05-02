extends BTAction

@export var max_angle_deviation: float = 0.7
@export var timeout_limit := 2.0

var dir: Vector2
var desired_velocity: Vector2
var time: float = 0.0

func _enter() -> void:
	time = 0.0
	dir = Vector2.LEFT * agent.character_data.direction
	#print(dir)
	var speed: float = agent.move_speed
	var rand_angle = randf_range(-max_angle_deviation, max_angle_deviation)
	desired_velocity = dir.rotated(rand_angle) * speed

func _tick(delta: float) -> Status:
	#print(agent.character_data.direction)
	time += delta
	if time > timeout_limit:
		return SUCCESS
	agent.character_ai_main.move(desired_velocity)
	agent.character_ai_main.update_direction()
	agent.character_ai_main.move_animation()
	return RUNNING
