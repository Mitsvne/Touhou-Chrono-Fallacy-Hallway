extends BTAction

enum State{NONE,常态,移动,技能,必杀,死亡}
@export var timeout_limit := 1.0
var time: float = 0.0

func _enter() -> void:
	time = 0.0
	var body := agent as CharacterBody2D
	if not body and agent.has_method("character"):
		body = agent.character as CharacterBody2D
	if body:
		body.velocity = Vector2.ZERO
	agent.character_ai_main.set_current_state(State.常态)

func _tick(delta: float) -> Status:
	time += delta
	if time > timeout_limit:
		return SUCCESS
	return RUNNING
