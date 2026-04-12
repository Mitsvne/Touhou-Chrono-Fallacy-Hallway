extends Camera2D

@onready var _1p: Node2D = $"../1P位置"

func _ready() -> void:
	position=_1p.position
	
