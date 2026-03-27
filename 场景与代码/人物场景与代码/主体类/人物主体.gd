extends Node
class_name Character_Main

@onready var character_data: Character_Data = $"../Character_Data"
@onready var character_ctrler: Character_Ctrler = $"../Character_Ctrler"

@export var character:CharacterBody2D
@export var anplayer: AnimationPlayer
@export var damage_number:PackedScene
@export var attack_bullet:PackedScene

enum State{常态,技能1,必杀1}
var team:String
var move_speed:int
var is_allow_move:bool=true
var attack_timer = Timer.new()
var skill_timer = Timer.new()
var is_attack_timer_timeout:bool=false
var is_skill_timer_timeout:bool=true
const KEEP_CURRENT:=-1
var current_state:int=-1:
	set(v):
		transition_state(current_state,v)
		current_state=v

func _ready() -> void:
	await owner.ready
	current_state=0
	move_speed=character.move_speed
	team=character.team
	attack_timer.wait_time = character.attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	attack_bullet=character.attack_bullet
	skill_timer.wait_time = character.skill_cd
	skill_timer.timeout.connect(_on_skill_timer_timeout)
	add_child(skill_timer)

##每帧效果函数
func _physics_process(delta: float) -> void:
	while true:
		var next_state:=get_next_state(current_state) as int
		if next_state==current_state:
			break
		current_state=next_state
	tick_physics(current_state,delta)
	if is_allow_move:
		character.velocity=Input.get_vector("move_left","move_right","move_up","move_down")*move_speed
		character.move_and_slide()

##状态每帧的效果函数
func tick_physics(state:State,_delta: float) -> void:
	match  state:
		State.常态:
			if Input.is_action_pressed(&"attack"):
				if attack_timer.is_stopped():
					attack_timer.start() # 如果按住且计时器未运行，则启动
					character_ctrler.shoot(attack_bullet,Vector2(50,0))
				elif is_attack_timer_timeout:
					is_attack_timer_timeout=false
					character_ctrler.shoot(attack_bullet,Vector2(50,0))
			else:
				if not attack_timer.is_stopped() and is_attack_timer_timeout:
					is_attack_timer_timeout=false
					attack_timer.stop() # 松开按键且计时归零，停止计时器
		State.技能1:
			pass
		State.必杀1:
			pass

##下一个状态逻辑函数
func get_next_state(state:State)->State:
	match state:
		State.常态:
			if Input.is_action_just_pressed(&"skill1") and is_skill_timer_timeout:
				if skill_timer.is_stopped():
					skill_timer.start()
				is_skill_timer_timeout=false
				return State.技能1
			if Input.is_action_just_pressed(&"ultimate") and character_data.mp>=100:
				return State.必杀1
		State.技能1:
			if not anplayer.is_playing():
				return State.常态
		State.必杀1:
			if not anplayer.is_playing():
				return State.常态
	return state

##状态动画播放函数
func transition_state(_from:State,to:State):
	match to:
		State.常态:
			anplayer.play("常态")
		State.技能1:
			anplayer.play("技能1")
		State.必杀1:
			anplayer.play("必杀1")

##受击处理函数
func _on_hurtbox_hurt(_hitbox: Variant, attack_data: AttackData) -> void:
	var damage:float = attack_data.damage
	character_data.hp-=damage
	var damage_node = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_node)   # 添加到场景树（例如主场景）
	damage_node.set_damage(damage, character.position, Color.WHITE)

##计时结束的回调函数
func _on_attack_timer_timeout():
	is_attack_timer_timeout=true;
func _on_skill_timer_timeout():
	is_skill_timer_timeout=true;
	skill_timer.stop()
	print("cd结束")
