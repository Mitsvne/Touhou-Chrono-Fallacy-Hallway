extends Node

signal settings_changed()  # 当设置被修改或应用时发出，UI可连接此信号刷新

const SAVE_PATH := "user://video_settings.cfg"

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1600, 900),
	Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)
]
const FPS_LIMITS: Array[int] = [30, 60, 90, 120, 0]
const FPS_LABELS: Array[String] = ["30 FPS", "60 FPS", "90 FPS", "120 FPS", "无上限"]
const DISPLAY_MODES: Array[Window.Mode] = [
	Window.MODE_WINDOWED, Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN
]
const DISPLAY_LABELS: Array[String] = ["窗口化", "全屏无边框", "全屏"]

var config := ConfigFile.new()
# 当前实际生效的设置缓存
var current_mode: Window.Mode = Window.MODE_WINDOWED
var current_size: Vector2i = Vector2i(1280, 720)
var current_fps: int = 60

func _ready() -> void:
	# 延迟加载，确保主循环和窗口已就绪
	call_deferred("load_and_apply")

func load_and_apply() -> void:
	load_settings()
	apply_all()
	settings_changed.emit()

## 应用所有画面设置
func apply_all() -> void:
	apply_fps(current_fps)
	apply_display_mode_internal(current_mode, current_size)

## 应用显示模式设置
func apply_display_mode(mode: Window.Mode) -> void:
	current_mode = mode
	apply_display_mode_internal(mode, current_size)
	save_settings()
	settings_changed.emit()

## 应用分辨率设置
func apply_resolution(new_size: Vector2i) -> void:
	current_size = new_size
	var win = get_window_or_null()
	if win and win.mode == Window.MODE_WINDOWED:
		win.size = new_size
		win.move_to_center()
	save_settings()
	settings_changed.emit()

## 应用帧率设置
func apply_fps(limit: int) -> void:
	current_fps = limit
	Engine.max_fps = limit
	save_settings()
	settings_changed.emit()

## 内部使用的模式切换，不负责发信号和保存（由上层调用决定）
func apply_display_mode_internal(mode: Window.Mode, size: Vector2i) -> void:
	var win = get_window_or_null()
	if not win:
		return
	win.mode = mode
	if mode == Window.MODE_WINDOWED:
		# 窗口模式：恢复之前保存的窗口大小
		win.size = size
		win.move_to_center()
	# 注意：全屏下尺寸由系统决定，这里我们只是记录 size，方便切回窗口时用

## 辅助方法，安全获取窗口
func get_window_or_null() -> Window:
	if get_tree():
		return get_tree().root
	return null

## 判断某个分辨率在窗口化时是否过大（被 UI 用于禁用选项）
func is_resolution_too_big_for_window(res: Vector2i) -> bool:
	var screen_idx = DisplayServer.window_get_current_screen()
	var usable = DisplayServer.screen_get_usable_rect(screen_idx).size
	var max_safe = Vector2i(usable.x, usable.y - 45)
	return res.x > max_safe.x or res.y > max_safe.y

## 从配置文件加载画面设置并应用
func load_settings() -> void:
	if config.load(SAVE_PATH) != OK:
		# 没有配置文件则保持默认值
		return
	current_mode = config.get_value("video", "display_mode", Window.MODE_WINDOWED)
	current_size = Vector2i(
		config.get_value("video", "window_width", 1280),
		config.get_value("video", "window_height", 720)
	)
	current_fps = config.get_value("video", "fps_limit", 60)

## 保存当前画面设置到配置文件
func save_settings() -> void:
	config.set_value("video", "display_mode", current_mode)
	config.set_value("video", "window_width", current_size.x)
	config.set_value("video", "window_height", current_size.y)
	config.set_value("video", "fps_limit", current_fps)
	config.save(SAVE_PATH)
