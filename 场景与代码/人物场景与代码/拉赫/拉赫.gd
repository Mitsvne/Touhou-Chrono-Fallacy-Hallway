extends CharacterBody2D
var character_name:String="拉赫莱蒂"
@onready var character_mian: Character_mian = $Character_mian
@onready var character_ctrler: Character_Ctrler = $class/Character_Ctrler
var team:String
@export var bullet1:PackedScene
@export var damage_number:PackedScene
func _ready():
	character_mian.hp_max=1000
	character_mian.hp=1000

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"attack2p"): # 替换为你的动作名称
		character_ctrler.shoot(bullet1,Vector2(-100,0))





func _on_hurtbox_hurt(_hitbox: Variant, attack_data: AttackData) -> void:
	var damage:float = attack_data.damage
	#var knockback = attack_data.knockback_force
	character_mian.hp-=damage
	var damage_node = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_node)   # 添加到场景树（例如主场景）
	damage_node.set_damage(damage, position, Color.WHITE)
