extends BTAction

@export var timeout_limit := 2.0
var time: float = 0.0

func _enter() -> void:
	time = 0.0
	agent.velocity=Vector2.ZERO
	agent.character_ai_main.update_direction()
	agent.character_ai_main.an_paly("常态")

func _tick(delta: float) -> Status:
	
	time += delta
	if time > timeout_limit:
		return SUCCESS
	return RUNNING
