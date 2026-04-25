extends Node2D

var target: CharacterBody2D
var offset: Vector2 = Vector2(50, -30)
var smooth_follow: bool = true
var follow_speed: float = 5.0

@export var prop_data: Prop_Data
@export var prop_ctrler: Prop_Ctrler
@export var audio: AudioStreamPlayer

func _ready():
	await get_tree().process_frame
	target=prop_data.prop_owner
	print("刻印之卷主人：",prop_data.prop_owner)

func _process(delta):
	prop_ctrler.set_direction(prop_data.prop_direction)
	if not target:
		return
	var target_pos = target.global_position + offset
	if smooth_follow:
		global_position = global_position.lerp(target_pos, follow_speed * delta)

func play_audio():
	audio.play()
