extends Control

@export var display_mode_option: OptionButton
@export var resolution_option: OptionButton
@export var fps_option: OptionButton

func _ready() -> void:
	_init_ui()
	# 连接 UI 信号
	display_mode_option.item_selected.connect(_on_display_mode_selected)
	resolution_option.item_selected.connect(_on_resolution_selected)
	fps_option.item_selected.connect(_on_fps_selected)
	# 监听全局设置变化，自动刷新界面
	VideoManager.settings_changed.connect(_update_ui_state)
	# 初始刷新一次（管理器已经加载好设置）
	_update_ui_state()

func _init_ui() -> void:
	# 直接从 VideoManager 拿常量，避免重复定义
	display_mode_option.clear()
	for i in range(VideoManager.DISPLAY_MODES.size()):
		display_mode_option.add_item(VideoManager.DISPLAY_LABELS[i])
		display_mode_option.set_item_metadata(i, VideoManager.DISPLAY_MODES[i])
	var screen_idx = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(screen_idx)
	resolution_option.clear()
	for res in VideoManager.RESOLUTIONS:
		if res.x <= screen_size.x and res.y <= screen_size.y:
			var idx = resolution_option.item_count
			resolution_option.add_item("%d x %d" % [res.x, res.y])
			resolution_option.set_item_metadata(idx, res)
	fps_option.clear()
	for i in range(VideoManager.FPS_LIMITS.size()):
		fps_option.add_item(VideoManager.FPS_LABELS[i])
		fps_option.set_item_metadata(i, VideoManager.FPS_LIMITS[i])

func _update_ui_state() -> void:
	var mode = VideoManager.current_mode
	var is_windowed = (mode == Window.MODE_WINDOWED)
	# 1. 更新显示模式选中项
	for i in range(display_mode_option.item_count):
		if display_mode_option.get_item_metadata(i) == mode:
			display_mode_option.select(i)
			break
	resolution_option.disabled = not is_windowed
	# 2. 动态禁用过大分辨率
	var screen_idx = DisplayServer.window_get_current_screen()
	var usable = DisplayServer.screen_get_usable_rect(screen_idx).size
	var max_safe = Vector2i(usable.x, usable.y - 45)
	var fallback_safe_idx = 0
	for i in range(resolution_option.item_count):
		var res: Vector2i = resolution_option.get_item_metadata(i)
		if is_windowed:
			var too_big = (res.x > max_safe.x or res.y > max_safe.y)
			resolution_option.set_item_disabled(i, too_big)
			if not too_big:
				fallback_safe_idx = i
		else:
			resolution_option.set_item_disabled(i, false)
	# 3. 确定当前应显示的分辨率（全屏时用屏幕物理尺寸）
	var current_size: Vector2i
	if is_windowed:
		current_size = VideoManager.current_size
	else:
		current_size = DisplayServer.screen_get_size()
	# 尝试在预设列表中匹配并选中
	var found := false
	for i in range(resolution_option.item_count):
		if resolution_option.get_item_metadata(i) == current_size:
			if is_windowed and resolution_option.is_item_disabled(i):
				break
			resolution_option.select(i)
			found = true
			break
	# 安全降级：窗口模式当前尺寸不安全时，选最大的安全分辨率
	if is_windowed and (not found or resolution_option.is_item_disabled(resolution_option.selected)):
		resolution_option.select(fallback_safe_idx)
	# 如果当前分辨率不在预设列表中（例如屏幕是 2560×1440，但列表里没有）
	if not found:
		var idx = resolution_option.item_count
		resolution_option.add_item("%d x %d (当前)" % [current_size.x, current_size.y])
		resolution_option.set_item_metadata(idx, current_size)
		resolution_option.select(idx)
		if not is_windowed:
			resolution_option.set_item_disabled(idx, true)
	# 4. 更新帧率选项
	for i in range(fps_option.item_count):
		if fps_option.get_item_metadata(i) == VideoManager.current_fps:
			fps_option.select(i)
			break
	# 如果预设列表里没有当前分辨率（比如屏幕是 1440p，但列表里没有），临时添加一项
	if not found:
		var idx := resolution_option.item_count
		resolution_option.add_item("%d x %d (当前)" % [current_size.x, current_size.y])
		resolution_option.set_item_metadata(idx, current_size)
		resolution_option.select(idx)
		# 全屏时新添加的项也要禁用（全屏下分辨率不可选）
		if not is_windowed:
			resolution_option.set_item_disabled(idx, true)

# 信号回调全部转向 VideoManager 管理器
func _on_display_mode_selected(idx: int) -> void:
	var mode: Window.Mode = display_mode_option.get_item_metadata(idx)
	VideoManager.apply_display_mode(mode)

func _on_resolution_selected(idx: int) -> void:
	var res: Vector2i = resolution_option.get_item_metadata(idx)
	VideoManager.apply_resolution(res)

func _on_fps_selected(idx: int) -> void:
	var fps: int = fps_option.get_item_metadata(idx)
	VideoManager.apply_fps(fps)
