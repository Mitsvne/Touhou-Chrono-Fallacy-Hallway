extends Node2D # 或 extends Control
@export var rotation_speed: float = 1.0 # 旋转速度（弧度/秒），可在编辑器调整
@export var rotation_direction: bool = true
func _process(delta):
	if rotation_direction:
		rotation += rotation_speed * delta
	else:
		rotation -= rotation_speed * delta
