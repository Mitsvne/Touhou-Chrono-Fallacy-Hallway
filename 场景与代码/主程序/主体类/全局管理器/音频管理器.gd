# audio_manager.gd (Autoload)
extends Node

## 背景音乐播放器
var _bgm_player: AudioStreamPlayer
## 音效播放器对象池
var _sfx_pool: Array[AudioStreamPlayer] = []
## 每个音频资源对应的并发上限（默认为 max_polyphony）
@export var max_polyphony: int = 4
## 音效播放器池初始大小
@export var pool_size: int = 8

## 总线名称（需在Audio面板中手动创建）
const BUS_MASTER := "Master"
const BUS_BGM := "BGM"
const BUS_SFX := "SFX"
const SETTINGS_PATH := "user://audio_settings.cfg"

func _ready() -> void:
	# 创建背景音乐播放器
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = BUS_BGM
	add_child(_bgm_player)
	# 预创建音效池
	for i in pool_size:
		var p := AudioStreamPlayer.new()
		p.bus = BUS_SFX
		add_child(p)
		_sfx_pool.append(p)


## 播放背景音乐（自动淡入，循环）
func play_bgm(stream: AudioStream, _fade_in_duration: float = 0.0, volume_db: float = 0.0) -> void:
	if _bgm_player.stream == stream and _bgm_player.playing:
		return
	# 淡出旧 BGM（此处简单实现，可扩展 Tween）
	if _bgm_player.playing:
		_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = volume_db
	_bgm_player.play()


## 停止背景音乐
func stop_bgm(_fade_out_duration: float = 0.5) -> void:
	if _bgm_player.playing:
		_bgm_player.stop()


## 播放音效（带并发控制）
func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	# 先统计当前正在播放同一个流的数量
	var count := 0
	var oldest_player: AudioStreamPlayer = null
	for p in _sfx_pool:
		if p.playing and p.stream == stream:
			count += 1
			if oldest_player == null:
				oldest_player = p

	# 如果已达到并发上限，直接复用最旧的那个播放器
	if count >= max_polyphony:
		if oldest_player != null:
			oldest_player.stop()
			oldest_player.stream = stream
			oldest_player.volume_db = volume_db
			oldest_player.pitch_scale = pitch_scale
			oldest_player.play()
			return oldest_player
		else:
			# 理论上不会发生
			pass

	# 找一个空闲的播放器
	for p in _sfx_pool:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = pitch_scale
			p.play()
			return p

	# 所有播放器都在忙碌中，动态创建一个新播放器并加入池（不推荐频繁发生）
	var new_p := AudioStreamPlayer.new()
	new_p.bus = BUS_SFX
	add_child(new_p)
	_sfx_pool.append(new_p)
	new_p.stream = stream
	new_p.volume_db = volume_db
	new_p.pitch_scale = pitch_scale
	new_p.play()
	return new_p

## 设置主音量（线性 0.0～1.0，转 dB）
func set_master_volume(linear: float) -> void:
	var db := linear_to_db(clampf(linear, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MASTER), db)

## 设置 BGM 音量
func set_bgm_volume(linear: float) -> void:
	var db := linear_to_db(clampf(linear, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_BGM), db)

## 设置 SFX 音量
func set_sfx_volume(linear: float) -> void:
	var db := linear_to_db(clampf(linear, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_SFX), db)

## 获取线性音量值（用于 UI 滑块显示）
func get_master_volume_linear() -> float:
	var db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	return db_to_linear(db)

func get_bgm_volume_linear() -> float:
	var db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM"))
	return db_to_linear(db)

func get_sfx_volume_linear() -> float:
	var db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	return db_to_linear(db)

## 保存当前总线音量到配置文件
func save_volume_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", get_master_volume_linear())
	config.set_value("audio", "bgm_volume", get_bgm_volume_linear())
	config.set_value("audio", "sfx_volume", get_sfx_volume_linear())
	config.save(SETTINGS_PATH)

## 从配置文件加载音量并应用
func load_volume_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	set_master_volume(config.get_value("audio", "master_volume", 1.0))
	set_bgm_volume(config.get_value("audio", "bgm_volume", 1.0))
	set_sfx_volume(config.get_value("audio", "sfx_volume", 1.0))
