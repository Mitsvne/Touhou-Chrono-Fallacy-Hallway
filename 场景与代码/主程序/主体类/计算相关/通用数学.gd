extends Node


## 生成n-m间的随机小数，并放入数组
func random_num(count: int, min_num: float, max_num: float, balanced: bool = false, 
	randomness: float = 1.0, is_shuffle = true) -> Array[float]:
	# 确保 start_angle < end_angle
	if min_num > max_num:
		var temp = min_num
		min_num = max_num
		max_num = temp
	var arr: Array[float] = []
	if balanced:
		var range_size = max_num - min_num
		var sector = range_size / count
		for i in range(count):
			var base = min_num + i * sector
			var offset = randf_range(-sector / 2, sector / 2) * clamp(randomness, 0.0, 1.0)
			arr.append(base + offset)
		if is_shuffle:
			arr.shuffle()  # 打乱顺序
	else:
		for i in range(count):
			arr.append(randf_range(min_num, max_num))
	return arr
