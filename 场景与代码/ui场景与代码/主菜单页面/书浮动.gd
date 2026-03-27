extends Node2D
@export var move_target: Vector2 = Vector2(163, 201)
@export var float_strength: float = 4.0      
@export var float_speed: float = 3.0         
var _time_passed: float = 0.0
var _origin_position: Vector2
var _is_moving: bool = true
				
func _ready():
	global_position = Vector2(700, move_target.y)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", move_target, 1.9)
	tween.tween_callback(_on_move_complete)

func _on_move_complete():
	_origin_position = position
	_is_moving = false

func _process(delta):
	if _is_moving:
		return
	_time_passed += delta
	var offset_y = sin(_time_passed * float_speed) * float_strength
	var offset_x = cos(_time_passed * float_speed * 0.1) * float_strength * 0.55
	position = _origin_position + Vector2(offset_x, offset_y)
