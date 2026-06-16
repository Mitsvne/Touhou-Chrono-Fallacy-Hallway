extends Control

@export var character_data: Character_Data

@export var bar: Control
@export var hp_bar: TextureProgressBar
@export var delay_hp_bar: TextureProgressBar
@export var mp_bar: TextureProgressBar
@export var delay_mp_bar: TextureProgressBar
@export var energy_bar: TextureProgressBar
@export var delay_energy_bar: TextureProgressBar
@export var avatar: TextureRect

var characters: Array[Node2D] = []
var fade_alpha: float = 0.3
var fade_duration: float = 0.2
var is_faded: bool = false
var tween: Tween
var _bound: bool = false


func _ready() -> void:
	if character_data:
		_bind(character_data)


## 初始化（关卡脚本赋值时调用）
func setup(cd: Character_Data) -> void:
	character_data = cd
	if not _bound and is_node_ready():
		_bind(cd)


func _bind(cd: Character_Data) -> void:
	if _bound: return
	_bound = true
	character_data = cd
	characters.assign(get_tree().get_nodes_in_group("characters"))
	cd.hp_changed.connect(update_hp)
	cd.mp_changed.connect(update_mp)
	cd.energy_changed.connect(update_energy)
	update_hp(cd.hp, cd.hp_max)
	update_mp(cd.mp, cd.mp_max)
	update_energy(cd.energy, cd.energy_max)
	update_avatar()


func _process(_delta):
	var valid_characters: Array[Node2D] = []
	for c in characters:
		if is_instance_valid(c):
			valid_characters.append(c)
	characters = valid_characters
	if characters.is_empty():
		if is_faded:
			fade_ui(1.0)
		return
	var ui_rect: Rect2 = get_global_rect().abs()
	var should_fade := false
	for char_node in characters:
		var player_screen_pos: Vector2 = char_node.get_global_transform_with_canvas().origin
		if ui_rect.has_point(player_screen_pos):
			should_fade = true
			break
	if should_fade and not is_faded:
		fade_ui(fade_alpha)
	elif not should_fade and is_faded:
		fade_ui(1.0)


func update_hp(hp: float, hp_max: float) -> void:
	var percentage := character_data.hp / float(character_data.hp_max)
	hp_bar.value = percentage
	create_tween().tween_property(delay_hp_bar, "value", percentage, 0.3)


func update_mp(mp: float, mp_max: float) -> void:
	var percentage := character_data.mp / float(character_data.mp_max)
	mp_bar.value = percentage
	create_tween().tween_property(delay_mp_bar, "value", percentage, 0.5)


func update_energy(energy: float, energy_max: float) -> void:
	var percentage := character_data.energy / character_data.energy_max
	energy_bar.value = percentage
	create_tween().tween_property(delay_energy_bar, "value", percentage, 0.3)


func update_avatar() -> void:
	if character_data and character_data.avatar and avatar:
		avatar.texture = character_data.avatar


func fade_ui(target_alpha: float) -> void:
	is_faded = (target_alpha < 1.0)
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, fade_duration)
