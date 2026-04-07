extends Node2D
@onready var 拉赫: CharacterBody2D = $".."
@export var move_target: Vector2 = Vector2(163, 201)
@export var float_strength: float = 4.0      
@export var float_speed: float = 3.0         
var _time_passed: float = 0.0
var _origin_position: Vector2=position
var _is_moving: bool = false
				
func _process(delta):
	if _is_moving:
		return
	_time_passed += delta
	var offset_y = sin(_time_passed * float_speed) * float_strength
	var offset_x = cos(_time_passed * float_speed * 0.1) * float_strength * 0.55
	position = _origin_position + Vector2(offset_x, offset_y)
