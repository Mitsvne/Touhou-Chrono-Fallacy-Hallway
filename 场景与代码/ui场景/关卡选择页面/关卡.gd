extends Button

@export var level_id: String = ""
@export var star_displays: Array[TextureRect]  # 三个星星图标
@onready var label: Label = $标签
@onready var stars_box: HBoxContainer = $星级

func _ready() -> void:
	label.text=level_id
	update_stars(GameData.get_stars(level_id))

func _process(_delta: float) -> void:
	if self.modulate.a!=1:
		label.modulate.a=self.modulate.a*0.8
	else:
		label.modulate.a=1


func update_stars(stars: int) -> void:
	for i in range(star_displays.size()):
		if i < stars:
			star_displays[i].visible = true
		else:
			star_displays[i].visible = false
