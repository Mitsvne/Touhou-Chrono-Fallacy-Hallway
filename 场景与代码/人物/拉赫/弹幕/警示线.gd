extends Node2D

@onready var anplayer: AnimationPlayer = $动画

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await anplayer.animation_finished
	queue_free()
