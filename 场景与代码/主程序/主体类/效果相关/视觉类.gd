extends Node2D
class_name VisualNode

@export var data :Node

func _ready() -> void:
	await data.ready
	await get_tree().process_frame
	#print(data.bullet_direction)
	#visual_mirror(data.bullet_direction)


## 镜像效果
func visual_mirror(dir: float):
	if dir == 1:
		return
	scale.x*=dir
	#if rotation!=0:
		#scale.y*=dir
	print(scale.x)
	
	
