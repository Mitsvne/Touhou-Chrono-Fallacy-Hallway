extends BaseButton
class_name PlayerUIColumn

## 栏位背景
@export var column_texture: Sprite2D;
## 栏位被选中时背景
@export var column_texture_select: Sprite2D;

## 是否被选中（鼠标移到上面视为选中）
var selected:bool = false;
## 此栏目中的物品
# var item:GameItem = null;


## 初始化栏位
func _pressed() -> void:
	column_texture_select.visible = false;
	pass
