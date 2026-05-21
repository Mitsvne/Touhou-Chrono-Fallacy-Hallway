class_name AccessoryData
extends Resource

@export var id: String
@export var accessory_name: String
@export_multiline var description: String
@export var icon: Texture2D

# 这个饰品携带的所有被动效果
@export var passive_effects: Array[AccessoryEffect] = []
