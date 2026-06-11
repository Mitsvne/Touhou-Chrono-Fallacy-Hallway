extends Node

const SAVE_PATH := "user://save_data.cfg"

signal character_changed(new_data: CharacterData)
signal deploy_character_changed(new_data: CharacterData)

# 存储每个关卡的最高星级，键是关卡ID（字符串），值是0~3的整数
var level_stars := {}
# 当前的关卡id
var current_level_id: String = "关卡1"
#全游戏所有的角色
var all_characters: Array[CharacterData] = [
	preload("res://场景与代码/人物/灵梦/本体/灵梦数据.tres"),
	preload("res://场景与代码/人物/早苗/本体/早苗数据.tres"),
	preload("res://场景与代码/人物/拉赫/本体/拉赫数据.tres")
]
#当前确认出战的角色
var current_deploy_character_data:CharacterData:
	set(value):
			current_deploy_character_data = value
			deploy_character_changed.emit(value)
#当前页面显示的角色
var current_character_data: CharacterData:
	set(value):
			current_character_data = value
			character_changed.emit(value)
#玩家当前已经解锁的角色
var unlocked_characters: Array[CharacterData] = []
#所有拥有的道具卡
var all_owned_cards: Array[ItemCardData] = []


func _ready() -> void:
	# 加载初始道具卡数据
	var card1 = load("res://场景与代码/道具卡/体力提升/体力提升.tres")
	var card2 = load("res://场景与代码/道具卡/灵力提升/灵力提升.tres")
	var card3 = load("res://场景与代码/道具卡/符卡威力提升/符卡威力提升.tres")
	#var card4 = load()
	all_owned_cards.append(card1)
	all_owned_cards.append(card2)
	all_owned_cards.append(card3)
	# 加载初始人物数据
	unlocked_characters.append(all_characters[0])
	unlocked_characters.append(all_characters[1])
	current_deploy_character_data=unlocked_characters[1]
	current_character_data=unlocked_characters[0]
	load_data()

## ==========================================
##         —— 安全的对外输入接口 ——
## ==========================================
## 获取当前关卡id
func get_current_level_id() -> String:
	return current_level_id

## 设置当前关卡id
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

## 通过名字快速获取某角色的静态资源
func get_character_data(char_name: String) -> CharacterData:
	for char_data in all_characters:
		if char_data.character_name == char_name:
			return char_data
	push_error("未找到名为 " + char_name + " 的角色资源")
	return null


## 保存数据
func save_data() -> void:
	var config := ConfigFile.new()
	for level in level_stars:
		config.set_value("stars", level, level_stars[level])
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
