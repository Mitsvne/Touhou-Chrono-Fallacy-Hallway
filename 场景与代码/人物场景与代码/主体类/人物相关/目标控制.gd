extends Node
class_name Target_Ctrler

var target:CharacterBody2D

func _ready() -> void:
	await get_tree().process_frame
	target=get_Target()
	print("7.Target_Ctrler初始化完成：",target)
	pass

func _process(_delta: float) -> void:
	pass

func get_Target():
	var team=owner.team
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character is CharacterBody2D and not character.is_in_group(team):
			return character
	return null

func get_Target_position():
	return target.position
