extends Node
class_name Character_Input
var input_arry=["move_left_1p","move_right_1p","move_up_1p","move_down_1p",
				"dash_1p","attack_1p","skill_1p","ultimate_1p",
				"move_left_2p","move_right_2p","move_up_2p","move_down_2p",
				"dash_2p","attack_2p","skill_2p","ultimate_2p"]
@export var move_left:String="move_left_1p":
	set(v):
		if v in input_arry:
			if v==move_left:
				return
			move_left=v
@export var move_right:String="move_right_1p":
	set(v):
		if v in input_arry:
			if v==move_right:
				return
			move_right=v
@export var move_up:String="move_up_1p":
	set(v):
		if v in input_arry:
			if v==move_up:
				return
			move_up=v
@export var move_down:String="move_down_1p":
	set(v):
		if v in input_arry:
			if v==move_down:
				return
			move_down=v
@export var dash:String="dash_1p":
	set(v):
		if v in input_arry:
			if v==dash:
				return
			dash=v
@export var attack:String="attack_1p":
	set(v):
		if v in input_arry:
			if v==attack:
				return
			attack=v
@export var skill:String="skill_1p":
	set(v):
		if v in input_arry:
			if v==skill:
				return
			skill=v
@export var ultimate:String="ultimate_1p":
	set(v):
		if v in input_arry:
			if v==ultimate:
				return
			ultimate=v

func _ready() -> void:
	print("3.Character_Input初始化完成")
	pass

func _process(_delta: float) -> void:
	#set_control_key(owner.team)
	pass

func set_control_key(team:String="1P") -> void:
	move_left="move_left_1p" if team=="1P" else "move_left_2p"
	move_right="move_right_1p" if team=="1P" else "move_right_2p"
	move_up="move_up_1p" if team=="1P" else "move_up_2p"
	move_down="move_down_1p" if team=="1P" else "move_down_2p"
	dash="dash_1p" if team=="1P" else "dash_2p"
	attack="attack_1p" if team=="1P" else "attack_2p"
	skill="skill_1p" if team=="1P" else "skill_2p"
	ultimate="ultimate_1p" if team=="1P" else "ultimate_2p"
