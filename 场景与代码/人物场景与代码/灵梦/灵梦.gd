extends CharacterBody2D

var move_speed:int=300
var character_name:String="博丽灵梦"
enum State{常态,技能1,必杀1}
var team:String
var is_skill1_cd:bool=false

@export var bullet1:PackedScene
@export var bullet2:PackedScene
@export var bullet3:PackedScene
@export var damage_number:PackedScene

@onready var shoot_timer: Timer = $计时器/弹幕发射间隔
@onready var skill1_cd: Timer = $计时器/技能1cd
@onready var anplayer: AnimationPlayer = $动画
#控制器导入
@onready var character_mian: Character_mian = $Character_mian
@onready var character_ctrler: Character_Ctrler = $class/Character_Ctrler
@onready var effect_ctrler: Effect_Ctrler = $class/Effect_Ctrler

func _ready():
	character_mian.hp=200

#下一个状态效果
func tick_physics(state:State,_delta: float) -> void:
	self.velocity=Input.get_vector("move_left","move_right","move_up","move_down")*move_speed
	move_and_slide()
	match  state:
		State.常态:
			#create_shadow($素材库)
			if Input.is_action_pressed(&"attack"): # 替换为你的动作名称
				if shoot_timer.is_stopped():
					character_ctrler.shoot(bullet1,Vector2(50,0))
					shoot_timer.start() # 如果按住且计时器未运行，则启动
			else:
				if not shoot_timer.is_stopped():
					shoot_timer.stop() # 松开按键，停止计时器
		State.技能1:
			skill1_cd.start()
			is_skill1_cd=true
			pass
		State.必杀1:
			pass

#下一个状态逻辑
func get_next_state(state:State)->State:
	match state:
		State.常态:
			if Input.is_action_just_pressed(&"skill1") and not is_skill1_cd:
				return State.技能1
			if Input.is_action_just_pressed(&"ultimate"):
				return State.必杀1
		State.技能1:
			if not anplayer.is_playing():
				return State.常态
		State.必杀1:
			if not anplayer.is_playing():
				return State.常态
	return state

#状态动画播放函数
func transition_state(_from:State,to:State):
	match to:
		State.常态:
			anplayer.play("常态")
		State.技能1:
			anplayer.play("技能1")
		State.必杀1:
			anplayer.play("必杀1")

func _on_弹幕发射间隔_timeout() -> void:
	#时间到，发射弹幕
	if anplayer.current_animation=="常态":
		character_ctrler.shoot(bullet1,Vector2(50,0))

func _on_技能1_cd_timeout() -> void:
	is_skill1_cd=false
	skill1_cd.stop()
	
func _on_hurtbox_hurt(_hitbox: Variant, attack_data: AttackData) -> void:
	var damage:float = attack_data.damage
	#var knockback = attack_data.knockback_force
	character_mian.hp-=damage
	var damage_node = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_node)   # 添加到场景树（例如主场景）
	damage_node.set_damage(damage, position, Color.WHITE)
