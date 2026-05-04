extends Control

@export var character:CharacterBody2D
@export var character_data:Character_Data

@export var bar:Control
@export var hp_bar: TextureProgressBar
@export var delay_hp_bar: TextureProgressBar
@export var mp_bar: TextureProgressBar
@export var delay_mp_bar: TextureProgressBar
@export var energy_bar: TextureProgressBar
@export var delay_energy_bar: TextureProgressBar
@export var avatars: PanelContainer

var characters: Array[Node2D] = []
var fade_alpha: float = 0.3 # 遮挡时的透明度
var fade_duration: float = 0.2 # 渐变动画的持续时间
var is_faded: bool = false
var tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	if not character_data:
		printerr("character_data 未在检查器中赋值！")
		return
	#获取所有人物
	characters.assign(get_tree().get_nodes_in_group("characters"))
	#连接信号
	character_data.hp_changed.connect(update_hp)
	character_data.mp_changed.connect(update_mp)
	character_data.energy_changed.connect(update_energy)
	#初始执行一次
	update_hp(character_data.hp,character_data.hp_max)
	update_mp(character_data.mp,character_data.hp_max)
	update_energy(character_data.energy,character_data.energy_max)
	update_avatar()
	#print("血条ui初始化完成 血量：%s 耐力：%s 魔力：%s"%[character_data.hp,character_data.energy,character_data.mp])

func _process(_delta):
	# 清理已删除的角色
	var valid_characters: Array[Node2D] = []
	for c in characters:
		if is_instance_valid(c):
			valid_characters.append(c)
	characters = valid_characters
	# 没有角色时恢复不透明
	if characters.is_empty():
		if is_faded:
			fade_ui(1.0)
		return
	# 获取 UI 的屏幕矩形（已用 .abs() 修正负尺寸）
	var ui_rect: Rect2 = get_global_rect().abs()
	var should_fade := false
	for char_node in characters:
		# 玩家的世界坐标转屏幕坐标
		var player_screen_pos: Vector2 = char_node.get_global_transform_with_canvas().origin
		if ui_rect.has_point(player_screen_pos):
			should_fade = true
			break   # 只要有一个角色遮挡，就触发半透明
	if should_fade and not is_faded:
		fade_ui(fade_alpha)
	elif not should_fade and is_faded:
		fade_ui(1.0)


## 更新血量
func update_hp(hp:float,hp_max:float):
	var percentage:=character_data.hp/float(character_data.hp_max)
	hp_bar.value=percentage
	create_tween().tween_property(delay_hp_bar,"value",percentage,0.3)

## 更新魔力值
func update_mp(mp:float,mp_max:float):
	var percentage:=character_data.mp/float(character_data.mp_max)
	mp_bar.value=percentage
	create_tween().tween_property(delay_mp_bar,"value",percentage,0.5)

## 更新耐力
func update_energy(energy:float,energy_max:float):
	var percentage:=character_data.energy/character_data.energy_max
	energy_bar.value=percentage
	create_tween().tween_property(delay_energy_bar,"value",percentage,0.3)

## 更新头像
func update_avatar():
	for child in avatars.get_children():
		if child is TextureRect and child.name==character.character_name:
			child.modulate.a = 1.0
		else:
			child.modulate.a = 0.0

# 处理透明度渐变动画
func fade_ui(target_alpha: float) -> void:
	is_faded = (target_alpha < 1.0)
	# 如果当前有正在播放的渐变，先停掉
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	# 缓动 modulate 属性的 alpha 值 (注意 Godot 4 中的语法是 "modulate:a")
	tween.tween_property(self, "modulate:a", target_alpha, fade_duration)
