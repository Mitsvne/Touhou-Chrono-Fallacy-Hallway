extends Node2D

@export var rotation_speed: float = 1.0 # 旋转速度（弧度/秒），可在编辑器调整
@onready var number_ring: Sprite2D = $数字
@onready var magic_array: Sprite2D = $法阵

	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_animation()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	number_ring.rotation -= rotation_speed * delta
	magic_array.rotation += rotation_speed * delta

func play_animation():
	var current_scale=scale
	scale=current_scale*0.2
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", current_scale*1.2, 0.2)
	tween.tween_interval(2)                       # 保持目标缩放一段时间
	tween.tween_property(self, "modulate:a", 0.0, 0.5)  # 透明度降为0
	# 可选：动画结束后自动隐藏或释放节点
	tween.tween_callback(queue_free)  # 如果不需要释放，换成 hide() 或其他逻辑
