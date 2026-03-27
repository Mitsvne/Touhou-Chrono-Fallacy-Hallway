extends CharacterBody2D
enum State{站立,移动,起跳,跳中循环,跳落循环,跳落地,冲刺,攻击1,攻击2,攻击3,受击,死亡}
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float
@export var can_combo:=false
var is_combo:=false
var run_speed:int=200	#移动速度
var jump_power:int=-600	#跳跃力
var acceleration:=run_speed/0.15	#加速度
var ground_states:=[State.站立,State.移动,State.跳落地,State.冲刺,State.攻击1,State.攻击2,State.攻击3,State.受击]	#地面动作列表
var current_direction := 1  # 当前朝向1=右, -1=左
var pending_damage:Damage	#待处理攻击
var dash_energy:float=20
@onready var an: AnimatedSprite2D = $动画帧数库
@onready var anplayer: AnimationPlayer = $动画
@onready var state_machine: StateMachine = $StateMachine
@onready var coyote_timer: Timer = $郊狼时间
@onready var stats: Stats = $Stats
@onready var invincible_time: Timer = $受击无敌时间


func _ready() -> void:
	scale.x = current_direction


func tick_physics(state:State,delta: float) -> void:
	if invincible_time.time_left>0:
		an.modulate.a=sin(Time.get_ticks_msec())*0.5+0.5
	else:
		an.modulate.a=1
	match  state:
		State.站立,State.移动,State.起跳,State.跳中循环,State.跳落循环:
			setdirect()
			move(delta)
		State.跳落地:
			pass
		State.冲刺:
			dash(500,delta)
		State.攻击1,State.攻击2,State.攻击3,State.受击:
			pass


#ad移动函数
func move(delta:float) -> void:
	var direction:=Input.get_axis("move_left","move_right")	#朝向
	#velocity.x=move_toward(velocity.x,direction*run_speed,acceleration*delta)	#x移动
	velocity.x=direction*run_speed	#x移动
	velocity.y+=gravity*delta #重力
	move_and_slide()


func setdirect() -> void:
	var direction:=Input.get_axis("move_left","move_right")	#朝向
	if not is_zero_approx(direction) and is_on_floor():
		var new_dir = sign(direction)  # 获取输入方向的正负号
		if new_dir != current_direction:
			current_direction = new_dir
			scale.x = -1	


func dash(speed:float,delta:float) -> void:
	velocity.y=0
	velocity.x=speed*current_direction
	move_and_slide()

#输入事件回调
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("attack") and can_combo:
		is_combo=true


#下一个状态判断函数
func get_next_state(state:State)->State:
	var direction:=Input.get_axis("move_left","move_right")	#朝向
	var is_stand := is_zero_approx(direction) and is_zero_approx(velocity.x)	#站立条件判定
	var can_jump:=is_on_floor() or coyote_timer.time_left>0	#跳跃条件,在地面或者郊狼时间未结束
	var should_jump:=can_jump and Input.is_action_just_pressed("jump")	#按键跳跃
	if should_jump:
		return State.起跳
	if pending_damage:
		return State.受击
	match state:
		State.站立:
			if not is_on_floor():
				return State.跳落循环
			if Input.is_action_just_pressed("attack"):
				return State.攻击1
			if Input.is_action_just_pressed("dash"):
				return State.冲刺
			if not is_stand:
				return State.移动
		State.移动:
			if not is_on_floor():
				return State.跳落循环
			if Input.is_action_just_pressed("attack"):
				return State.攻击1
			if Input.is_action_just_pressed("dash"):
				return State.冲刺
			if is_stand:
				return State.站立
		State.起跳:
			if is_on_floor():
				return State.跳落地
			if Input.is_action_just_pressed("dash"):
				return State.冲刺
			if not anplayer.is_playing():
				return State.跳中循环
		State.跳中循环:
			if Input.is_action_just_pressed("dash"):
				return State.冲刺
			if velocity.y>=0:
				return State.跳落循环
		State.跳落循环:
			if Input.is_action_just_pressed("dash"):
				return State.冲刺
			if is_on_floor():
				return State.跳落地
		State.跳落地:
			if not anplayer.is_playing():
				return State.站立
		State.冲刺:
			if not anplayer.is_playing():
				return State.站立
		State.攻击1:
			if not anplayer.is_playing():
				return State.攻击2 if is_combo else State.站立
		State.攻击2:
			if not anplayer.is_playing():
				return State.攻击3 if is_combo else State.站立
		State.攻击3:
			if not anplayer.is_playing():
				return State.站立
		State.受击:
			if not anplayer.is_playing():
				pending_damage=null
				return State.站立
	return state


#状态动画播放函数
func transition_state(from:State,to:State):
	if from not in ground_states and to in ground_states:
		coyote_timer.stop()
	match to:
		State.站立:
			anplayer.play("站立")
		State.移动:
			anplayer.play("移动")
		State.起跳:
			anplayer.play("起跳")
			velocity.y=jump_power
			coyote_timer.stop()
		State.跳中循环:
			anplayer.play("跳中循环")
		State.跳落循环:
			anplayer.play("跳落循环")
			if from in ground_states:
				coyote_timer.start()
		State.跳落地:
			anplayer.play("跳落地")
		State.冲刺:
			anplayer.play("冲刺")
			
			stats.energy-=dash_energy
		State.攻击1:
			anplayer.play("攻击1")
			is_combo=false
		State.攻击2:
			anplayer.play("攻击2")
			is_combo=false
		State.攻击3:
			anplayer.play("攻击3")
			is_combo=false
		State.受击:
			anplayer.play("受击")
			stats.hp-=pending_damage.value
			invincible_time.start()
			print("人物：被命中,当前生命值:",stats.hp)


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	if invincible_time.time_left>0:
		print("受击无敌")
		return
	pending_damage=Damage.new()
	pending_damage.value=20
	pending_damage.damage_owner=hitbox.owner
