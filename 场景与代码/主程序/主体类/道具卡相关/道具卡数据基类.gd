class_name ItemCardData
extends Resource

@export var card_id: String = ""
@export var card_name: String = "未命名卡牌"
@export var icon: Texture2D
@export_multiline var description: String = ""
# 一张卡可以包含多个效果
@export var effects: Array[CardEffect] = []
