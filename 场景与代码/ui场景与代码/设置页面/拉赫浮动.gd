extends AnimatedSprite2D

# 浮动的参数
@export var float_strength: float = 6.0
@export var float_speed: float = 3
var _time_passed: float = 0.0
var _origin_position: Vector2
var _is_floating: bool = false 

func _ready():
	modulate.a = 0
	move_character_with_float(self, Vector2(96, -62), Vector2(96, 219), 1.5)
	await get_tree().create_timer(1.5).timeout
	_origin_position = position   # 记录移动后的正确位置
	_is_floating = true

func _process(delta):
	if _is_floating:
		_time_passed += delta
		var offset_y = sin(_time_passed * float_speed) * float_strength
		var offset_x = sin(_time_passed * float_speed * 0.7) * float_strength * 0.55
		position = _origin_position + Vector2(offset_x, offset_y)

func move_character_with_float(character: AnimatedSprite2D, initial_position: Vector2, target_position: Vector2, animation_length: float) -> void:
	character.position = initial_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(character, "position", target_position, animation_length)
	tween.tween_property(character, "modulate:a", 1.0, animation_length * 0.5)
