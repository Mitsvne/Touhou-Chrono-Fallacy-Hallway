extends AnimatedSprite2D
@export var float_strength: float = 3.0      
@export var float_speed: float = 3.0         
var _time_passed: float = 0.0
var _origin_position: Vector2=position
func _process(delta):
	_time_passed += delta
	var offset_y = sin(_time_passed * float_speed) * float_strength
	var offset_x = cos(_time_passed * float_speed * 0) * float_strength * 0.55
	position = _origin_position + Vector2(offset_x, offset_y)
