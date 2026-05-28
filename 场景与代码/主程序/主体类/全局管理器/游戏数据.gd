extends Node

const SAVE_PATH := "user://save_data.cfg"

# 存储每个关卡的最高星级，键是关卡ID（字符串），值是0~3的整数
var level_stars := {}
var current_level_id: String = "关卡1"                # 当前的关卡id
var current_character: String = "博丽灵梦"             # 当前选择的角色

# 角色数据：字典的字典
var characters: Dictionary = {
	"博丽灵梦": {
		"hp": 300, "hp_max": 300,
		"mp": 100,  "mp_max": 100,
		"energy": 100, "energy_max": 100,
		"power": 10, "speed": 400,
		"skill":"技能1",
		"ultimate":"必杀1",
		"item_card":"",
		"path":"res://场景与代码/人物/灵梦/本体/灵梦.tscn",
		"skill1_icon":preload("res://素材/人物素材/灵梦/符卡/技能1.png"),
		"skill2_icon":preload("res://素材/人物素材/灵梦/符卡/技能2.png"),
		"ultimate1_icon":preload("res://素材/人物素材/灵梦/符卡/必杀1.png"),
		"ultimate2_icon":preload("res://素材/人物素材/灵梦/符卡/必杀2.png")
	},
	"东风谷早苗": {
		"hp": 300, "hp_max": 300,
		"mp": 120,  "mp_max": 120,
		"energy": 80, "energy_max": 80,
		"power": 8, "speed": 500,
		"skill":"技能1",
		"ultimate":"必杀1",
		"item_card":"",
		"path":preload("res://场景与代码/人物/早苗/本体/早苗.tscn"),
		"skill1_icon":preload("res://素材/人物素材/早苗/符卡/技能1.png"),
		"skill2_icon":preload("res://素材/人物素材/早苗/符卡/技能2.png"),
		"ultimate1_icon":preload("res://素材/人物素材/早苗/符卡/必杀1.png"),
		"ultimate2_icon":preload("res://素材/人物素材/早苗/符卡/必杀2.png")
	}
}

func _ready() -> void:
	load_data()

## ==========================================
##         —— 安全的对外输入接口 ——
## ==========================================
func get_current_level_id() -> String:
	return current_level_id

func set_current_level_id(level_id: String) -> void:
	current_level_id=level_id

func get_current_character() -> String:
	return current_character

func set_current_character(character: String) -> void:
	current_character=character
	save_data()

## 获取关卡星级
func get_stars(level_id: String) -> int:
	return level_stars.get(level_id, 0)

## 设置关卡星级
func set_stars(level_id: String, stars: int) -> void:
	# 只有新星级更高时才更新
	if stars > get_stars(level_id):
		level_stars[level_id] = stars
		save_data()

## 获取某个角色的完整数据
func get_character(char_id: String) -> Dictionary:
	return characters.get(char_id, {})
	
## 获取某个角色的某个数据
func get_stat(char_id: String, stat: String, default = 0):
	return characters.get(char_id, {}).get(stat, default)

## 更新某个属性（同时触发保存）
func set_character_stat(char_id: String, stat: String, value) -> void:
	if not characters.has(char_id):
		return
	characters[char_id][stat] = value
	save_data()   # 沿用你已有的保存机制





## 保存数据
func save_data() -> void:
	var config := ConfigFile.new()
	for level in level_stars:
		config.set_value("stars", level, level_stars[level])
	config.set_value("Player", "current_character", current_character)
	for char_id in characters:
		var stats = characters[char_id]
		for stat in stats:
			config.set_value("char_" + char_id, stat, stats[stat])
	config.save(SAVE_PATH)

## 加载数据
func load_data() -> void:
	var config := ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		# 没有存档文件，使用默认值，不需要做任何事
		return
	# 1. 读取关卡星星数据
	if config.has_section("stars"):
		for level_key in config.get_section_keys("stars"):
			level_stars[level_key] = config.get_value("stars", level_key)
	# 2. 读取当前登场角色
	if config.has_section("Player"):
		current_character = config.get_value("Player", "current_character")
	# 3. 读取角色数据
	for section in config.get_sections():
		# 只处理以 "char_" 开头的节（表示角色数据）
		if section.begins_with("char_"):
			var char_id = section.substr(5)   # 去掉前缀得到角色ID，如 "warrior"
			# 确保角色字典中有这个ID的入口（如果默认没有，则创建一个空字典，防止新角色丢失）
			if not characters.has(char_id):
				characters[char_id] = {}
			# 逐个读取角色属性，若存档中缺少某个属性，则保留当前默认值（不清空）
			for stat in config.get_section_keys(section):
				characters[char_id][stat] = config.get_value(section, stat)
