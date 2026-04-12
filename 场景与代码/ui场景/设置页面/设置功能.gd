extends Control

@export var bgmslider: HSlider
@export var seslider: HSlider

func _ready() -> void:
	load_audio_settings()

func save_audio_settings():
	var config = ConfigFile.new()
	var bgm_vol = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Bgm"))
	var se_vol = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Se"))
	config.set_value("audio", "bgm_volume", bgm_vol)
	config.set_value("audio", "se_volume", se_vol)
	config.save("user://settings.cfg")

func load_audio_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return # 如果配置文件不存在，就使用默认值
	# 读取并设置音量
	var bgm_vol = config.get_value("audio", "bgm_volume", 0.0)
	var se_vol = config.get_value("audio", "se_volume", 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Bgm"), bgm_vol)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Se"), se_vol)
	# 更新滑块的位置
	bgmslider.value = db_to_linear(bgm_vol)
	seslider.value = db_to_linear(se_vol)

# 设置bgm总线音量
func _on_bgm_value_changed(value: float) -> void:
	var db_value = linear_to_db(value)
	var master_bus_index = AudioServer.get_bus_index(&"Bgm")
	AudioServer.set_bus_volume_db(master_bus_index, db_value)
	save_audio_settings()

# 设置音效总线音量
func _on_se_value_changed(value: float) -> void:
	var db_value = linear_to_db(value)
	var master_bus_index = AudioServer.get_bus_index(&"Se")
	AudioServer.set_bus_volume_db(master_bus_index, db_value)
	save_audio_settings()
