extends Node2D

@onready var anim: AnimatedSprite2D = $动画
@onready var audio: AudioStreamPlayer = $音效
var anim_finished = false
var audio_finished = false

func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)
	audio.finished.connect(_on_audio_finished)

func _on_anim_finished():
	anim_finished = true
	check_all_finished()

func _on_audio_finished():
	audio_finished = true
	check_all_finished()

func check_all_finished():
	if anim_finished and audio_finished:
		queue_free()
	
