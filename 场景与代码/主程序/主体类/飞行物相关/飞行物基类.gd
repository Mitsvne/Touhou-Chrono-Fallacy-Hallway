extends Area2D
class_name Bullet

@export var mp:float=0.0

@export_group("节点配置", "")
@export var anplayer: AnimationPlayer
@export var bullet_data: Bullet_Data
@export var bullet_ctrler: Bullet_Ctrler
@export var effect_ctrler: Effect_Ctrler
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox

func _ready() -> void:
	if not _check_property_settings:
		push_error("Bullet必要属性未设置完全！")
		return
	self.area_entered.connect(_on_area_entered)
	if hurtbox:
		hurtbox.hurt.connect(_on_hurtbox_hurt)
	await get_tree().process_frame
	if bullet_data.skill_data:
		mp=bullet_data.skill_data.mp_add
	else:
		mp=2
	init()
	pass

func _process(_delta: float) -> void:
	pass

## 检查是否有属性未设置
func _check_property_settings() -> bool:
	if not bullet_data:
		printerr("bullet_data未设置！")
		return false
	if not bullet_ctrler:
		printerr("bullet_ctrler未设置！")
		return false
	if not anplayer:
		printerr("anplayer未设置！")
		return false
	if not hitbox:
		printerr("hitbox未设置！")
		return false
	return true

## 碰撞回调
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.team) and area.owner.is_in_group("characters"):
		bullet_data.bullet_owner.character_data.mp+=mp
		bullet_ctrler.disable_box(hitbox,true)
		if hurtbox:
			bullet_ctrler.disable_box(hurtbox,true)
		hit()

## 受击回调
func _on_hurtbox_hurt(box: Hitbox, attack_data: AttackData) -> void:
	if box.owner.is_in_group("bullets"):
		bullet_data.hp-=attack_data.damage
		if bullet_data.hp<=0:
			bullet_ctrler.disable_box(hitbox,true)
			bullet_ctrler.disable_box(hurtbox,true)
			hurt()

func _calculate_damage(box:Hitbox) -> float:
	var final_damage:float
	if bullet_data.skill_data:
		var hits_array = bullet_data.skill_data.hits
		var current_hit_data: SkillHitData = hits_array[box.hit_index]
		final_damage=bullet_data.power*current_hit_data.damage_multiplier
	elif box.attack_data.damage_multiplier!=0:
		final_damage=bullet_data.power*box.attack_data.damage_multiplier
	else:
		final_damage=box.attack_data.damage
	return final_damage

##-------------------------子类可覆写函数---------------------------##

## 飞行物初始化
func init() -> void:
	pass

## 飞行物伤害初始化
func init_damage() -> void:
	hitbox.attack_data.damage=_calculate_damage(hitbox)

## 碰撞效果
func hit() -> void:
	bullet_ctrler.stop_move()
	if anplayer.has_animation(&"hit"):
		anplayer.play(&"hit")
	await anplayer.animation_finished
	queue_free()

## 受击效果
func hurt() -> void:
	bullet_ctrler.stop_move()
	if anplayer.has_animation(&"hurt"):
		anplayer.play(&"hurt")
	else:
		anplayer.play(&"hit")
	await anplayer.animation_finished
	queue_free()
