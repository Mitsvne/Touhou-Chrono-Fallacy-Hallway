extends Control

@export var masterslider: HSlider
@export var bgmslider: HSlider
@export var sfxslider: HSlider

func _ready() -> void:
	load_audio_settings()

## 保存设置值到settings.cfg
func save_audio_settings():
	AudioManager.save_volume_settings()

## 加载音频设置
func load_audio_settings():
	AudioManager.load_volume_settings()
	# 从 AudioManager 获取线性音量值并更新滑块
	masterslider.value = AudioManager.get_master_volume_linear()
	bgmslider.value = AudioManager.get_bgm_volume_linear()
	sfxslider.value = AudioManager.get_sfx_volume_linear()

## 设置音乐总线音量
func _on_bgm_value_changed(value: float) -> void:
	AudioManager.set_bgm_volume(value)
	save_audio_settings()

## 设置音效总线音量
func _on_sfx_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	save_audio_settings()

## 设置主音量总线音量
func _on_master_value_changed(value: float) -> void:
	AudioManager.set_master_volume(value)
	save_audio_settings()
