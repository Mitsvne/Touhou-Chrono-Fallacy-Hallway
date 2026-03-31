extends Node
class_name Character_Main

@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var character:CharacterBody2D
@export var anplayer: AnimationPlayer
@export var damage_number:PackedScene
@export var attack_bullet:PackedScene

enum State{常态,技能1,必杀1,死亡}
var team:String
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float
var move_speed:int
var current_velocity: Vector2 = Vector2.ZERO
var acceleration: float   # 加速度（像素/秒²）
var friction: float       # 减速度（像素/秒²）
var direct:float
var is_allow_move:bool=true
var is_alive:bool=true
var attack_timer = Timer.new()
var skill_timer = Timer.new()
var is_attack_timer_timeout:bool=false
var is_skill_timer_timeout:bool=true
const KEEP_CURRENT:=-1
var current_state:int=-1:
	set(v):
		transition_state(current_state,v)
		current_state=v

var move_left:String="move_left_1p"
var move_right:String="move_right_1p"
var move_up:String="move_up_1p"
var move_down:String="move_down_1p"
var attack:String="attack_1p"
var skill:String="skill_1p"
var ultimate:String="ultimate_1p"


##初始化函数
func _ready() -> void:
	await get_tree().process_frame
	#移动参数传递
	move_speed=character.move_speed
	acceleration=character.acceleration
	friction=character.friction
	#状态，朝向，队伍
	current_state=0
	direct=character.scale.x if character.team=="1P" else -character.scale.x
	team=character.team
	is_alive=true
	#计时器
	attack_timer.wait_time = character.attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	attack_bullet=character.attack_bullet
	skill_timer.wait_time = character.skill_cd
	skill_timer.timeout.connect(_on_skill_timer_timeout)
	add_child(skill_timer)
	#控制按键
	set_control_key()
	print("Character_Main初始化完成")


##每帧效果函数
func _physics_process(delta: float) -> void:
	while true:
		var next_state:=get_next_state(current_state) as int
		if next_state==current_state:
			break
		current_state=next_state
	tick_physics(current_state,delta)
	if is_allow_move and not is_dead():
		move(move_speed,delta)
		#character.velocity=Input.get_vector(move_left,move_right,move_up,move_down)*move_speed
		#character.move_and_slide()


##惯性移动函数
func move(max_speed:float,delta):
	if character_ctrler.is_gravity:
		current_velocity.y += gravity * delta
	var input_dir = Input.get_vector(move_left,move_right,move_up,move_down)
	var target_direction = input_dir.normalized()
	if input_dir != Vector2.ZERO:
		if current_velocity.length() > 0.01:
			var dot = current_velocity.normalized().dot(target_direction)
			if dot < 0:  # 按方向相反的键急停（夹角大于90度）
				current_velocity = Vector2.ZERO
		var target_velocity = target_direction*max_speed
		current_velocity = current_velocity.move_toward(target_velocity, acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, friction * delta)
	character.velocity = current_velocity
	character.move_and_slide()


##状态每帧的效果函数
func tick_physics(state:State,_delta: float) -> void:
	match  state:
		State.常态:
			if Input.is_action_pressed(attack):
				if attack_timer.is_stopped():
					attack_timer.start() # 如果按住且计时器未运行，则启动
					character_ctrler.shoot(attack_bullet,Vector2(50*direct,0))
				elif is_attack_timer_timeout:
					is_attack_timer_timeout=false
					character_ctrler.shoot(attack_bullet,Vector2(50*direct,0))
			else:
				if not attack_timer.is_stopped() and is_attack_timer_timeout:
					is_attack_timer_timeout=false
					attack_timer.stop() # 松开按键且计时归零，停止计时器
		State.技能1:
			pass
		State.必杀1:
			pass
		State.死亡:
			is_alive=false


##下一个状态逻辑函数
func get_next_state(state:State)->State:
	if is_dead():
			return State.死亡
	match state:
		State.常态:
			if Input.is_action_just_pressed(skill) and is_skill_timer_timeout:
				if skill_timer.is_stopped():
					skill_timer.start()
				is_skill_timer_timeout=false
				return State.技能1
			if Input.is_action_just_pressed(ultimate) and character_data.mp>=100:
				return State.必杀1
		State.技能1:
			if not anplayer.is_playing():
				return State.常态
		State.必杀1:
			if not anplayer.is_playing():
				return State.常态
	return state


##状态动画播放函数
func transition_state(_from:State,to:State) -> void:
	match to:
		State.常态:
			an_paly("常态")
		State.技能1:
			an_paly("技能1")
		State.必杀1:
			an_paly("必杀1")
		State.死亡:
			an_paly("死亡")


##动画播放函数
func an_paly(an_name:String):
	if anplayer.has_animation(an_name):
		anplayer.play(an_name)
	else:
		print("未找到 %s 动画"%[an_name])
		return


##受击处理函数
func _on_hurtbox_hurt(_hitbox: Variant, attack_data: AttackData) -> void:
	var damage:float = attack_data.damage
	character_data.hp-=damage
	var damage_node = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_node)   # 添加到场景树（例如主场景）
	damage_node.set_damage(damage, character.position, Color.WHITE)


func is_dead():
	if character_data.hp<=0 or not is_alive:
		return true






##根据队伍设置控制按键
func set_control_key() -> void:
	move_left="move_left_1p" if character.team=="1P" else "move_left_2p"
	move_right="move_right_1p" if character.team=="1P" else "move_right_2p"
	move_up="move_up_1p" if character.team=="1P" else "move_up_2p"
	move_down="move_down_1p" if character.team=="1P" else "move_down_2p"
	attack="attack_1p" if character.team=="1P" else "attack_2p"
	skill="skill_1p" if character.team=="1P" else "skill_2p"
	ultimate="ultimate_1p" if character.team=="1P" else "ultimate_2p"

##计时结束的回调函数
func _on_attack_timer_timeout():
	is_attack_timer_timeout=true;
func _on_skill_timer_timeout():
	is_skill_timer_timeout=true;
	skill_timer.stop()
	print("cd结束")
