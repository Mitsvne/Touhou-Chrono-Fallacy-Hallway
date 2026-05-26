extends Node2D

var target: CharacterBody2D
var offset: Vector2 = Vector2(-50, -30)
var smooth_follow: bool = true
var follow_speed: float = 5.0

@export var prop_data: Prop_Data
@export var prop_ctrler: Prop_Ctrler
@export var anplayer: AnimationPlayer
@export var audio: AudioStreamPlayer


func _ready():
	await get_tree().process_frame
	target=prop_data.prop_owner
	scale.x=prop_data.prop_direction
	#print("刻印之卷主人：",prop_data.prop_owner)

func _process(delta):
	if not target:
		return
	if anplayer.current_animation=="常态":
		if prop_data.prop_direction != target.character_data.direction:
				#print(prop_data.prop_direction,target.character_data.direction)
				prop_data.prop_direction=target.character_data.direction
				#print(prop_data.prop_direction,target.character_data.direction)
				scale.x*=-1
		var target_pos:Vector2=Vector2.ZERO
		target_pos.x = target.global_position.x + offset.x * target.character_data.direction
		target_pos.y = target.global_position.y + offset.y
		if smooth_follow:
			global_position = global_position.lerp(target_pos, follow_speed * delta)

func play_audio():
	audio.play()
