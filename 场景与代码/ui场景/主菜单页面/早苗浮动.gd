extends AnimatedSprite2D
# 浮动的参数
@export var float_strength: float = 5.0
@export var float_speed: float = 2.5
var _time_passed: float = 0.0
var _origin_position: Vector2
var _is_floating: bool = false

func start_floating(target_position: Vector2):
	_origin_position = target_position
	_time_passed = 0.0
	_is_floating = true
	print(name, " 开始浮动，位置: ", _origin_position)

func _process(delta):
	if not _is_floating:
		return
	_time_passed += delta
	var offset_y = sin(_time_passed * float_speed) * float_strength
	var offset_x = cos(_time_passed * float_speed * 0.7) * float_strength * 0.55
	position = _origin_position + Vector2(offset_x, offset_y)
