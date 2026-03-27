extends Node2D
#@onready var tile_map: TileMapLayer = $地图
#@onready var camera_2d: Camera2D = $人物/相机



func _ready() -> void:
	pass
	#var used:= tile_map. get_used_rect()
	#var tile_size:=tile_map.tile_set.tile_size
	#camera_2d.limit_top = used.position.y * tile_size.y
	#camera_2d.limit_right = used.end.x * tile_size.x
	#camera_2d.limit_bottom = used.end.y * tile_size.y
	#camera_2d.limit_left = used.position.x * tile_size.x
