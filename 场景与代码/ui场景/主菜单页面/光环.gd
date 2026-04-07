extends Node2D # 或 extends Control
@export var move_target: Vector2 = Vector2(100, 205)
@export var rotation_speed: float = 1.0 # 旋转速度（弧度/秒），可在编辑器调整

func _ready():
	global_position = Vector2(700, move_target.y)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", move_target, 1.5)

func _process(delta):
	rotation += rotation_speed * delta
