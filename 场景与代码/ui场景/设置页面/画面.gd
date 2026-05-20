extends Control
# 视频设置界面控制脚本：管理显示模式、分辨率、帧率限制

const SAVE_PATH := "user://video_settings.cfg"
# 配置文件保存路径

@export var display_mode_option: OptionButton
# 显示模式下拉框（窗口化/全屏无边框/全屏）
@export var resolution_option: OptionButton
# 分辨率下拉框（仅在窗口模式下可用）
@export var fps_option: OptionButton
# 帧率限制下拉框

var config := ConfigFile.new()
# 用于保存/加载设置的配置文件实例

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]
# 可选的预设分辨率列表

const FPS_LIMITS: Array[int] = [30, 60, 90, 120, 0]
# 帧率限制数值，0 表示无上限
const FPS_LABELS: Array[String] = ["30 FPS", "60 FPS", "90 FPS", "120 FPS", "无上限"]
# 帧率选项的显示文字

const DISPLAY_MODES: Array[Window.Mode] = [
	Window.MODE_WINDOWED,
	Window.MODE_FULLSCREEN,
	Window.MODE_EXCLUSIVE_FULLSCREEN
]
# 支持的三种显示模式：窗口化、全屏无边框、全屏
const DISPLAY_LABELS: Array[String] = ["窗口化", "全屏无边框", "全屏"]
# 显示模式的显示文字

func _ready() -> void:
	# 初始化UI选项、加载上次设置、连接信号
	_init_ui()
	load_settings()
	display_mode_option.item_selected.connect(_on_display_mode_selected)
	resolution_option.item_selected.connect(_on_resolution_selected)
	fps_option.item_selected.connect(_on_fps_selected)

func _init_ui() -> void:
	# 填充三个下拉框的初始选项，根据当前屏幕过滤分辨率
	display_mode_option.clear()
	for i in range(DISPLAY_MODES.size()):
		display_mode_option.add_item(DISPLAY_LABELS[i])
		display_mode_option.set_item_metadata(i, DISPLAY_MODES[i])
		# 将 Window.Mode 枚举值存为元数据，方便后续读取
	
	var screen_idx := DisplayServer.window_get_current_screen()
	var screen_size := DisplayServer.screen_get_size(screen_idx)
	# 获取当前所在屏幕的物理像素大小
	
	resolution_option.clear()
	for res in RESOLUTIONS:
		# 仅添加不超过物理屏幕大小的分辨率
		if res.x <= screen_size.x and res.y <= screen_size.y:
			var idx := resolution_option.item_count
			resolution_option.add_item("%d x %d" % [res.x, res.y])
			resolution_option.set_item_metadata(idx, res)
			# 存储对应的 Vector2i 以便直接使用
	
	fps_option.clear()
	for i in range(FPS_LIMITS.size()):
		fps_option.add_item(FPS_LABELS[i])
		fps_option.set_item_metadata(i, FPS_LIMITS[i])
		# 存储实际的帧率数值

func _update_ui_state() -> void:
	# 根据当前窗口状态（模式、大小）刷新所有下拉框的选中和禁用状态
	var win := get_window()
	var is_windowed := (win.mode == Window.MODE_WINDOWED)
	
	# 1. 更新显示模式下拉菜单的选中项
	for i in range(display_mode_option.item_count):
		if display_mode_option.get_item_metadata(i) == win.mode:
			display_mode_option.select(i)
			break
	
	# 根据全屏/窗口状态决定是否禁用分辨率选择
	resolution_option.disabled = not is_windowed
	
	var screen_idx := DisplayServer.window_get_current_screen()
	var usable_size := DisplayServer.screen_get_usable_rect(screen_idx).size
	# 获取屏幕可用区域（排除任务栏等）
	
	# 窗口化模式下，预留标题栏高度（约45像素），计算安全的最大窗口尺寸
	var max_safe_window_size := Vector2i(usable_size.x, usable_size.y - 45)
	var fallback_safe_idx := 0  # 记录最后一个安全的分辨率索引
	
	# 2. 动态控制分辨率选项的可用性（窗口模式下禁用过大的分辨率）
	for i in range(resolution_option.item_count):
		var res: Vector2i = resolution_option.get_item_metadata(i)
		
		if is_windowed:
			# 窗口模式下，若分辨率超出安全范围则禁用该选项
			var is_too_big := (res.x > max_safe_window_size.x or res.y > max_safe_window_size.y)
			resolution_option.set_item_disabled(i, is_too_big)
			if not is_too_big:
				fallback_safe_idx = i  # 不断更新为最后一个可用的安全索引
		else:
			# 全屏模式下所有分辨率都可以选（虽然实际由屏幕决定）
			resolution_option.set_item_disabled(i, false)
	
	# 3. 选中当前分辨率（窗口模式用窗口大小，全屏用屏幕大小）
	var current_size := win.size if is_windowed else DisplayServer.screen_get_size()
	var res_found := false
	
	for i in range(resolution_option.item_count):
		if resolution_option.get_item_metadata(i) == current_size:
			# 如果当前选项在窗口模式下被禁用，说明是从全屏切回来的超标分辨率
			if is_windowed and resolution_option.is_item_disabled(i):
				break
			resolution_option.select(i)
			res_found = true
			break
	
	# 安全降级：窗口模式下如果当前分辨率不安全，自动选择最大的安全分辨率
	if is_windowed and (not res_found or resolution_option.is_item_disabled(resolution_option.selected)):
		resolution_option.select(fallback_safe_idx)
		var safe_res: Vector2i = resolution_option.get_item_metadata(fallback_safe_idx)
		win.size = safe_res
		win.move_to_center()
	elif not res_found and not is_windowed:
		# 全屏下遇到特殊分辨率（不在预设列表中），临时添加显示
		var idx := resolution_option.item_count
		resolution_option.add_item("%d x %d (当前)" % [current_size.x, current_size.y])
		resolution_option.set_item_metadata(idx, current_size)
		resolution_option.select(idx)
	
	# 4. 更新帧率下拉菜单
	var current_fps := Engine.max_fps
	for i in range(fps_option.item_count):
		if fps_option.get_item_metadata(i) == current_fps:
			fps_option.select(i)
			break

func apply_display_mode(mode: Window.Mode) -> void:
	# 切换显示模式（窗口化/全屏等）
	var win := get_window()
	win.mode = mode
	if mode == Window.MODE_WINDOWED:
		# 切回窗口时先刷新UI状态（执行安全降级），再应用选中的分辨率
		_update_ui_state()
		var sel_idx := resolution_option.selected
		if sel_idx >= 0:
			apply_resolution(resolution_option.get_item_metadata(sel_idx))
	else:
		_update_ui_state()
	save_settings()

func apply_resolution(vsize: Vector2i) -> void:
	# 仅在窗口模式下调整窗口大小并居中
	var win := get_window()
	if win.mode != Window.MODE_WINDOWED:
		return
	win.size = vsize
	win.move_to_center()
	save_settings()

func apply_fps(limit: int) -> void:
	# 设置引擎的最大帧率（0为无上限）
	Engine.max_fps = limit
	save_settings()

func _on_display_mode_selected(idx: int) -> void:
	# 下拉框信号回调：应用选择的显示模式
	apply_display_mode(display_mode_option.get_item_metadata(idx))

func _on_resolution_selected(idx: int) -> void:
	# 下拉框信号回调：应用选择的分辨率
	apply_resolution(resolution_option.get_item_metadata(idx))

func _on_fps_selected(idx: int) -> void:
	# 下拉框信号回调：应用选择的帧率限制
	apply_fps(fps_option.get_item_metadata(idx))


##--------保存与加载---------#
func save_settings() -> void:
	# 将当前视频设置写入配置文件
	var win := get_window()
	config.set_value("video", "display_mode", win.mode)
	
	# 保存的分辨率：窗口模式记实际窗口大小，全屏记当前选中的分辨率（用于切回窗口时恢复）
	var save_size: Vector2i
	if win.mode == Window.MODE_WINDOWED:
		save_size = win.size
	else:
		if resolution_option.selected >= 0:
			save_size = resolution_option.get_item_metadata(resolution_option.selected)
		else:
			save_size = Vector2i(1280, 720)  # 兜底默认值
	
	config.set_value("video", "window_width", save_size.x)
	config.set_value("video", "window_height", save_size.y)
	config.set_value("video", "fps_limit", Engine.max_fps)
	config.save(SAVE_PATH)

func load_settings() -> void:
	# 从配置文件加载视频设置，若无配置文件则使用默认值并刷新UI
	if config.load(SAVE_PATH) != OK:
		_update_ui_state()  # 无保存文件，直接用当前默认状态
		return
	
	var mode: Window.Mode = config.get_value("video", "display_mode", Window.MODE_WINDOWED)
	var w: int = config.get_value("video", "window_width", 1280)
	var h: int = config.get_value("video", "window_height", 720)
	var fps: int = config.get_value("video", "fps_limit", 60)
	
	Engine.max_fps = fps  # 先设置帧率限制
	
	var win := get_window()
	if mode == Window.MODE_WINDOWED:
		# 窗口模式：设置大小和模式，然后居中
		win.size = Vector2i(w, h)
		win.mode = mode
		win.move_to_center()
	else:
		# 全屏模式：先设大小再切模式，避免闪烁
		win.size = Vector2i(w, h)
		win.mode = mode
	
	_update_ui_state()  # 最后刷新UI确保选项与实际状态一致
