extends Node

const SAVE_PATH := "user://save_data.cfg"

# 存储每个关卡的最高星级，键是关卡ID（字符串），值是0~3的整数
var level_stars := {}
var current_level_id: String = ""
func _ready() -> void:
	load_data()







## ==========================================
##         —— 安全的对外输入接口 ——
## ==========================================
func get_current_level_id() -> String:
	return current_level_id

func set_current_level_id(level_id: String) -> void:
	current_level_id=level_id

## 获取关卡星级
func get_stars(level_id: String) -> int:
	return level_stars.get(level_id, 0)

## 设置关卡星级
func set_stars(level_id: String, stars: int) -> void:
	# 只有新星级更高时才更新
	if stars > get_stars(level_id):
		level_stars[level_id] = stars
		save_data()

## 保存数据
func save_data() -> void:
	var config := ConfigFile.new()
	for level in level_stars:
		config.set_value("stars", level, level_stars[level])
	config.save(SAVE_PATH)

## 加载数据
func load_data() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for level in config.get_section_keys("stars"):
			level_stars[level] = config.get_value("stars", level)
