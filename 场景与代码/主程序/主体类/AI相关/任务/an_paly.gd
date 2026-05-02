extends BTAction

@export var an_name :String

func _enter() -> void:
	if an_name:
		agent.character_ai_main.an_paly(an_name)
	else:
		printerr("未输入动画名称")

func _tick(_delta: float):
	if not agent.character_ai_main.anplayer.is_playing():
		return RUNNING
