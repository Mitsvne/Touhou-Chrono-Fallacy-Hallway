extends Node2D
@export var 灵梦: AnimatedSprite2D
@export var 早苗: AnimatedSprite2D
@export var 魔理沙: AnimatedSprite2D
@export var 拉赫: AnimatedSprite2D
var delay:float=0.2

func _ready():
	# 初始化所有角色为透明
	for child in [灵梦, 早苗, 魔理沙, 拉赫]:
		child.modulate.a = 0
	# 顺序移动角色
	move_character_with_float(拉赫, Vector2(700, 250), Vector2(135, 250), 1.5)
	await get_tree().create_timer(delay*2).timeout
	move_character_with_float(魔理沙, Vector2(700, 250), Vector2(465, 290), 1.0)
	await get_tree().create_timer(delay).timeout
	move_character_with_float(早苗, Vector2(700, 240), Vector2(475, 240), 1.0)
	await get_tree().create_timer(delay).timeout
	move_character_with_float(灵梦, Vector2(700, 170), Vector2(525, 170), 1.0)
	await get_tree().create_timer(delay).timeout

func move_character_with_float(character: AnimatedSprite2D, initial_position: Vector2, target_position: Vector2, animation_length: float) -> void:
	# 设置初始位置
	character.position = initial_position
	# 创建Tween进行移动和淡入
	var tween = create_tween()
	tween.set_parallel(true)  # 并行执行
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(character, "position", target_position, animation_length)
	tween.tween_property(character, "modulate:a", 1.0, animation_length * 0.5)
