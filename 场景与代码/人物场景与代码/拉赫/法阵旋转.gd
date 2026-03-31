extends Node2D # 或 extends Control
@export var rotation_speed: float = 1.0 # 旋转速度（弧度/秒），可在编辑器调整

func _process(delta):
	rotation += rotation_speed * delta
