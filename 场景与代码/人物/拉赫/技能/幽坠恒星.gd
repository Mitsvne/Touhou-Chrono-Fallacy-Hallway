extends SkillNode
## 幽坠恒星 —— 上方随机位置预警线 → 延迟 → 火球落下

@export var bullet: PackedScene
@export var count: int = 10
@export var x_min: float = -300.0
@export var x_max: float = 300.0
@export var y_offset: float = 100.0
@export var warning_color: Color = Color(1.825, 0.868, 0.742, 1.0)
@export var line_thickness: float = 0.3
@export var audio_player: AudioStreamPlayer
@export var shine_star: PackedScene
@export var magic_array: PackedScene
var _x_list: Array[float]
var _angles: Array[float]

func execute() -> void:
	if anplayer and not anim_name.is_empty() and anplayer.has_animation(anim_name):
		anplayer.play(anim_name)
		await anplayer.animation_finished
	else:
		warning()
		await get_tree().create_timer(0.3, false).timeout
		fire()
	finished.emit()


func warning_and_fire():
	warning()
	await get_tree().create_timer(0.3, false).timeout
	fire()


func warning() -> void:
	var pos = agent.global_position
	_angles = Math.random_num(count, -140.0, -40.0) as Array[float]
	_x_list = Math.random_num(count, x_min, x_max, true) as Array[float]
	for i in range(count):
		character_ctrler.add_warning_line(pos,
			Vector2(_x_list[i], y_offset), _angles[i], 999, 1,
			warning_color, line_thickness, line_thickness, line_thickness)


func fire() -> void:
	if audio_player:
		audio_player.play()
	var pos = agent.global_position
	for i in range(count):
		character_ctrler.shoot(bullet, Vector2(_x_list[i], y_offset), _angles[i], pos)
		
func add_shine_star() -> void:
	character_ctrler.add_effect(shine_star, agent.global_position, Vector2(0, 50))

func add_magic_array() -> void:
	character_ctrler.add_effect(magic_array, agent.global_position, Vector2(0, 50))
