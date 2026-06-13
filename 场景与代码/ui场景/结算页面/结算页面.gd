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
	# 通过 transition_to 重载场景并进入开场→正常流程
	GameStateManager.transition_to(GameStateManager.STATE_OPENING, get_tree().current_scene.scene_file_path)

## 返回选关
func _on_back_pressed() -> void:
	GameStateManager.purge_in_game_history()
	GameStateManager.transition_to(GameStateManager.STATE_LEVEL_SEL, "res://场景与代码/ui场景/关卡选择页面/关卡选择.tscn")
