extends Level


func setup():
	pass


func opening():
	print("关卡2：开场")
	await get_tree().create_timer(0.5, false).timeout
