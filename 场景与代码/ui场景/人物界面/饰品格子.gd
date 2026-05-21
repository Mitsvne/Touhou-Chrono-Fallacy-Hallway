class_name AccessorySlot
extends BaseButton # 👈 改为继承所有按钮的基类

var accessory_data: AccessoryData = null
var is_equipped_slot: bool = false
var slot_index: int = -1

func display(data: AccessoryData) -> void:
	accessory_data = data
	
	if accessory_data != null:
		# 使用 set() 是一种安全的做法：如果节点有这个属性就赋值，没有就忽略
		# 这样无论你外面的节点是 Button 还是 TextureButton 都不用担心报错
		if "text" in self:
			self.text = accessory_data.accessory_name
		if "texture_normal" in self:
			self.texture_normal = accessory_data.icon
		elif "icon" in self:
			self.icon = accessory_data.icon
			
		tooltip_text = accessory_data.description
	else:
		if "text" in self:
			self.text = "[空槽位]" if is_equipped_slot else ""
		if "texture_normal" in self:
			self.texture_normal = null
		elif "icon" in self:
			self.icon = null
		tooltip_text = "没有任何饰品"
