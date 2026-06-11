extends Node2D

# 让节点逐渐消失（淡出）
func fade_out(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)

# 让节点慢慢显现（淡入）
func fade_in(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)
