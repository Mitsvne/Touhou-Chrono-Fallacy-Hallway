extends Node2D

var target: CharacterBody2D
var offset: Vector2 = Vector2(50, -30)
var smooth_follow: bool = true
var follow_speed: float = 10.0

@export var prop_data: Prop_Data
@export var prop_ctrler: Prop_Ctrler

func _ready():
	await get_tree().process_frame
	target=prop_data.prop_owner
	print("刻印之卷主人：",prop_data.prop_owner)
	#target=get_prop_owner()

func _process(delta):
	if not target:
		return
	var target_pos = target.global_position + offset
	if smooth_follow:
		# 平滑跟随，产生延迟效果（适合幽灵、光环等）
		global_position = global_position.lerp(target_pos, follow_speed * delta)
	else:
		# 严格跟随
		global_position = target_pos

func get_prop_owner():
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character is CharacterBody2D and character.character_name=="拉赫莱蒂":
			return character
	return null
