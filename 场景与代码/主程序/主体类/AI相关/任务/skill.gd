extends BTAction

@export var an_name :String
var timeout_limit := 1.0
var time: float = 0.0
enum State{NONE,常态,移动,技能,必杀,死亡}


func _enter() -> void:
	time = 0.0
	agent.character_ai_main.set_current_state(State.技能)
	if an_name:
		agent.character_ai_main.an_paly(an_name)
	else:
		printerr("未输入动画名称")
	var length = agent.character_ai_main.anplayer.get_animation(an_name).length
	timeout_limit=length


func _tick(delta: float) -> Status:
	time += delta
	if time > timeout_limit:
		return SUCCESS
	return RUNNING
