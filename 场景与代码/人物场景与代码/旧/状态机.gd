extends Node
class_name StateMachine
const KEEP_CURRENT:=-1
var current_state:int=-1:
	set(v):
		owner.transition_state(current_state,v)
		current_state=v

func _ready() -> void:
	await owner.ready
	current_state=0

func _physics_process(delta: float) -> void:
	while true:
		var next_state:=owner.get_next_state(current_state) as int
		if next_state==current_state:
			break
		current_state=next_state
	owner.tick_physics(current_state,delta)
