extends Node
class_name Character_Main

@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var character_input: Character_Input
@export var character:CharacterBody2D
@export var anplayer: AnimationPlayer
@export var hurtbox: Hurtbox
@export var damage_number:PackedScene
@export var attack_bullet:PackedScene
@export var attack_effect:PackedScene

enum State{NONE,常态,移动,技能1,必杀1,冲刺,死亡}
var current_state: State = State.常态 :
	set(v):
		print(current_state)
		if current_state == v: return
		exit_state(current_state)
		transition_state(current_state,v)
		current_state=v
		enter_state(v)

var team:String
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float
var move_speed:int
var current_velocity: Vector2 = Vector2.ZERO
var acceleration: float
var friction: float
var direction:float
var is_allow_key_move:bool=true
var is_alive:bool=true
var attack_timer = Timer.new()
var skill_timer = Timer.new()
var is_attack_timer_timeout:bool=false
var is_skill_timer_timeout:bool=true

var move_left:String="move_left_1p"
var move_right:String="move_right_1p"
var move_up:String="move_up_1p"
var move_down:String="move_down_1p"
var dash:String="dash_1p"
var attack:String="attack_1p"
var skill:String="skill_1p"
var ultimate:String="ultimate_1p"

##初始化函数
func _ready() -> void:
	await character.ready                          #等人物先加载
	team=character_data.team                       #队伍
	move_speed=character.move_speed                #移速
	acceleration=character.acceleration            #加速度
	friction=character.friction                    #减速度
	direction=character_data.direction             #朝向
	character_data.direction_changed.connect(update_direction)
	update_direction(direction)
	#普攻和技能cd计时器
	attack_timer.wait_time = character.attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	skill_timer.wait_time = character.skill_cd
	skill_timer.timeout.connect(_on_skill_timer_timeout)
	add_child(skill_timer)
	#按队伍分配控制按键
	character_input.set_control_key(team)
	move_left=character_input.move_left
	move_right=character_input.move_right
	move_up=character_input.move_up
	move_down=character_input.move_down
	dash=character_input.dash
	attack=character_input.attack
	skill=character_input.skill
	ultimate=character_input.ultimate
	print("5.Character_Main初始化完成:",character)


##每帧效果函数
func _physics_process(delta: float) -> void:
	var next_state = get_next_state(current_state)
	if next_state != current_state:
		current_state = next_state
	tick_physics(current_state,delta)
	if character_ctrler.is_gravity:
		current_velocity.y += gravity * delta
	is_allow_key_move=character_ctrler.get_is_key_moving()
	if is_allow_key_move and not is_dead() and not character_ctrler.get_is_moving():
		move(move_speed,delta)

##状态每帧的效果函数
func tick_physics(state:State,_delta: float) -> void:
	match  state:
		State.常态:
			fire_bullet()
		State.移动:
			move_animation()
			fire_bullet()
		State.冲刺,State.技能1,State.必杀1:
			pass
		State.死亡:
			character_ctrler.set_invincible(true)
			character_ctrler.apply_gravity(true)
			is_alive=false

##下一个状态逻辑函数
func get_next_state(state:State)->State:
	if is_dead():
			return State.死亡
	if state in [State.常态, State.移动]:
		var common = idle_move()
		if common != State.NONE:
			return common
	match state:
		State.常态:
			if Input.is_action_pressed(move_left) or Input.is_action_pressed(move_right):
				return State.移动
		State.移动:
			if not Input.is_action_pressed(move_left) and not Input.is_action_pressed(move_right):
				return State.常态
		State.冲刺:
			if not anplayer.is_playing():
				return State.常态
		State.技能1:
			if not anplayer.is_playing():
				return State.常态
		State.必杀1:
			if not anplayer.is_playing():
				return State.常态
	return state

##状态进入时
func enter_state(state:State):
	match state:
		pass

##状态退出时
func exit_state(state:State):
	match state:
		pass

##状态动画播放函数
func transition_state(_from:State,to:State) -> void:
	match to:
		State.常态:
			an_paly("常态")
		State.移动:
			move_animation()
		State.技能1:
			an_paly("技能1")
		State.必杀1:
			an_paly("必杀1")
		State.冲刺:
			dash_animation()
		State.死亡:
			an_paly("死亡")

##移动动画播放函数
func move_animation():
	var dir:=Input.get_axis(move_left,move_right)
	if dir*direction>0:
		an_paly("前进")
	else:
		an_paly("后退")

##冲刺动画播放函数
func dash_animation():
	var dir:=Input.get_axis(move_left,move_right)
	if dir*direction<0:
		if anplayer.has_animation("冲刺后"):
			an_paly("冲刺后")
		else:
			an_paly("冲刺")
	else:
		if anplayer.has_animation("冲刺前"):
			an_paly("冲刺前")
		else:
			an_paly("冲刺")

##动画播放函数
func an_paly(an_name:String):
	if anplayer.has_animation(an_name):
		anplayer.play(an_name)
	else:
		printerr("缺失动画: ", an_name)
		return

##常态，移动状态通用效果
func idle_move() -> State:
	if Input.is_action_just_pressed(skill) and is_skill_timer_timeout:
		if skill_timer.is_stopped():
			skill_timer.start()
		is_skill_timer_timeout=false
		return State.技能1
	if Input.is_action_just_pressed(ultimate) and character_data.mp>=100:
		character_data.mp-=100
		return State.必杀1
	if Input.is_action_just_pressed(dash) and character_data.energy>=25:
		character_data.energy-=25
		return State.冲刺
	return State.NONE

##受击处理函数
func _on_hurtbox_hurt(hitbox: Variant, attack_data: AttackData) -> void:
	if not character_ctrler.get_is_allow_behit():
		print("不可受击状态")
		return
	var damage:float = attack_data.damage
	var attack_type:int =  attack_data.attack_type
	var hitstop:float =  attack_data.hitstop
	var attack_effect_node = attack_effect.instantiate()
	var damage_node = damage_number.instantiate()
	var attack_effect_position:Vector2=attack_effect_node.get_random_point_in_overlap(hitbox,hurtbox)
	character_data.hp-=damage
	get_tree().current_scene.add_child(damage_node)
	damage_node.set_damage(damage, character.position, Color.WHITE)
	get_tree().current_scene.add_child(attack_effect_node)
	if attack_effect_position != null:
		attack_effect_node.set_attack_effect(attack_type,attack_effect_position)
	else:
		attack_effect_node.set_attack_effect(attack_type,hitbox.global_position)
	attack_effect_node.set_hitstop(hitstop)
	
##惯性移动函数
func move(max_speed:float,delta):
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

##更新朝向
func update_direction(direct:float):
	direction=direct
	character.scale.x=direction

##判断是否死亡
func is_dead():
	if character_data.hp<=0 or not is_alive:
		return true

##普攻弹幕发射
func fire_bullet():
	if Input.is_action_pressed(attack):
		if attack_timer.is_stopped():
			attack_timer.start()
			character_ctrler.shoot(attack_bullet,Vector2(50*direction,0))
		elif is_attack_timer_timeout:
			is_attack_timer_timeout=false
			character_ctrler.shoot(attack_bullet,Vector2(50*direction,0))
	else:
		if not attack_timer.is_stopped() and is_attack_timer_timeout:
			is_attack_timer_timeout=false
			attack_timer.stop()

##计时结束的回调函数
func _on_attack_timer_timeout():
	is_attack_timer_timeout=true;

func _on_skill_timer_timeout():
	is_skill_timer_timeout=true;
	skill_timer.stop()
