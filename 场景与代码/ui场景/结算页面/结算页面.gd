extends CanvasLayer

@export var star_textures: Array[TextureRect]  # 拖入三个星星节点
@export var label: Label
@export var reset_button: Button

var stars:int          #结算星级

func _ready() -> void:
	EventBus.level_complete.connect(_on_level_complete)
	reset_button.grab_focus()
	for star in star_textures:
		star.modulate.a=0

func _on_level_complete(level_id:String,stars_num:int):
	stars=stars_num
	GameData.set_stars(level_id,stars_num)
	set_label()
	animate_stars()

## 标题内容
func set_label():
	if not label:
		return
	if stars==0:
		label.text="退至失败"
	else:
		label.text="退至成功"

## 星星动画
func animate_stars() -> void:
	for i in range(stars):
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(star_textures[i], "modulate:a", 1.0, 0.3)        # 淡入
		tween.tween_property(star_textures[i], "scale", Vector2(1.3, 1.3), 0.3) # 放大
		tween.set_parallel(false)
		tween.tween_property(star_textures[i], "scale", Vector2(1.0, 1.0), 0.15)
		await get_tree().create_timer(0.3).timeout

## 重置关卡按钮
func _on_reset_pressed() -> void:
	await get_tree().process_frame
	get_tree().reload_current_scene()

## 返回选关
func _on_back_pressed() -> void:
	var transition_state = GameStateManager.get_node("切换")
	transition_state.next_scene_path = "res://场景与代码/ui场景/关卡选择页面/关卡选择.tscn"
	transition_state.next_state_name = "关卡选择"
	GameStateManager.change_state("切换")
