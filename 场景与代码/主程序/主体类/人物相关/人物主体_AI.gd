extends Node
## 人物主体类，状态机
class_name Character_AI_Main

@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var character:CharacterBody2D
@export var anplayer: AnimationPlayer
@export var hurtbox: Hurtbox
@export var bt_player: BTPlayer
@export var damage_number:PackedScene
@export var attack_effect:PackedScene

enum State{NONE,常态,移动,技能1,技能2,技能3,技能4,必杀,死亡}
var current_state: State = State.常态 :
	set(v):
		if current_state == v: return
		exit_state(current_state)
		transition_state(current_state,v)
		#print("%s => %s"%[State.keys()[current_state],State.keys()[v]])
		current_state=v
		enter_state(v)
var target :CharacterBody2D
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float
var current_velocity: Vector2 = Vector2.ZERO
var is_allow_key_move:bool=true
var is_alive:bool=true

## 初始化函数
func _ready() -> void:
	await character.ready                          #等人物先加载
	character_data.direction_changed.connect(set_direction)
	character.scale.x = character_data.direction   #赋予初始朝向
	target = character_ctrler.get_target()
	print("4.Character_AI_Main初始化完成:",character)

## 每帧效果函数
func _physics_process(delta: float) -> void:
	#print("velocity:",character.velocity)
	var next_state = get_next_state(current_state)
	if next_state != current_state:
		current_state = next_state
	tick_physics(current_state,delta)
	if character_ctrler.is_gravity:
		current_velocity.y += gravity * delta
	if not bt_player.active:
		move(character_data.move_speed,delta)
	if not GameStateManager.is_current_state(GameStateManager.STATE_PLAYING):
		bt_player.active=false


## 状态每帧的效果函数
func tick_physics(state:State,_delta: float) -> void:
	match state:
		State.常态:
			update_direction()
		State.移动:
			move_animation()
		State.死亡:
			character_ctrler.set_invincible(true)
			character_ctrler.apply_gravity(true)
			is_alive=false
			bt_player.active=false

## 常态，移动状态通用效果
func idle_move() -> State:
	if InputManager.is_action_just_pressed("skill1_AI"):
		return State.技能1
	if InputManager.is_action_just_pressed("skill2_AI"):
		return State.技能2
	if InputManager.is_action_just_pressed("skill3_AI"):
		return State.技能3
	if InputManager.is_action_just_pressed("skill4_AI"):
		return State.技能4
	if InputManager.is_action_just_pressed("ultimate_AI") and character_data.mp>=100:
		return State.必杀
	return State.NONE

## 下一个状态逻辑函数
func get_next_state(state:State)->State:
	if is_dead():
			return State.死亡
	if state in [State.常态, State.移动]:
		var common = idle_move()
		if common != State.NONE:
			return common
	if bt_player.active:
		match state:
			State.常态:
				if character.velocity.length()!= 0:
					return State.移动
			State.移动:
				if character.velocity.length()== 0:
					return State.常态
			State.技能1,State.技能2,State.技能3,State.技能4,State.必杀:
				if not anplayer.is_playing():
					return State.常态
	else:
		match state:
			State.常态:
				if InputManager.is_action_pressed("move_left_AI") or InputManager.is_action_pressed("move_right_AI"):
					return State.移动
			State.移动:
				if not InputManager.is_action_pressed("move_left_AI") and not InputManager.is_action_pressed("move_right_AI"):
					return State.常态
			State.技能1,State.技能2,State.技能3,State.技能4,State.必杀:
				if not anplayer.is_playing():
					return State.常态
	return state

## 状态进入时
func enter_state(state:State):
	match state:
		State.死亡:
			EventBus.character_dead.emit(character_data.team)

## 状态退出时
func exit_state(state:State):
	match state:
		pass

## 状态动画播放函数
func transition_state(_from:State,to:State) -> void:
	match to:
		State.常态:
			an_paly("常态")
		State.移动:
			move_animation()
		State.死亡:
			an_paly("死亡")
		State.技能1:
			an_paly("技能1")
		State.技能2:
			an_paly("技能2")
		State.技能3:
			an_paly("技能3")
		State.技能4:
			an_paly("技能4")

## 移动动画播放函数
func move_animation():
	var dir:=character.velocity.x
	if dir*character_data.direction>0:
		an_paly("前进")
	else:
		an_paly("后退")

## 动画播放函数
func an_paly(an_name:String):
	if anplayer.has_animation(an_name):
		anplayer.play(an_name)
	else:
		printerr("缺失动画: ", an_name)
		return

## 受击处理函数
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
	if character_ctrler.get_is_allow_losehp():
		character_data.hp-=damage
	if character_data.hp<=0:
		attack_effect_position=hitbox.global_position
		attack_type=4
		hitstop=0.15
	get_tree().current_scene.add_child(damage_node)
	damage_node.set_damage(damage, character.position, Color.WHITE)
	get_tree().current_scene.add_child(attack_effect_node)
	if attack_effect_position != null:
		attack_effect_node.set_attack_effect(attack_type,attack_effect_position)
	else:
		attack_effect_node.set_attack_effect(attack_type,hitbox.global_position)
	attack_effect_node.set_hitstop(hitstop)

## 判断是否死亡
func is_dead():
	if character_data.hp<=0 or not is_alive:
		return true

## 惯性移动函数
func move(max_speed:float,delta):
	var input_dir = InputManager.get_vector("move_left_AI", "move_right_AI", "move_up_AI", "move_down_AI")
	var target_direction = input_dir.normalized()
	if input_dir != Vector2.ZERO:
		if current_velocity.length() > 0.01:
			var dot = current_velocity.normalized().dot(target_direction)
			if dot < 0:  # 按方向相反的键急停（夹角大于90度）
				current_velocity = Vector2.ZERO
		var target_velocity = target_direction*max_speed
		current_velocity = current_velocity.move_toward(target_velocity, character_data.acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, character_data.friction * delta)
	character.velocity = current_velocity
	character.move_and_slide()

## 更新朝向：让人物始终盯着目标看
func update_direction():
	if not is_instance_valid(target):
		return
	var target_pos = target.global_position
	var self_pos = character.global_position
	# 计算目标在左还是在右
	var diff_x = target_pos.x - self_pos.x
	# 设置一个微小的死区（例如5像素），防止重合时疯狂转身
	if abs(diff_x) > 20.0:
		var new_dir = 1.0 if diff_x > 0 else -1.0
		character_data.direction = new_dir

## 设置朝向：处理视觉翻转和逻辑数值同步
func set_direction(_direct: float):
	character.scale.x *=  -1
	#print("direction：",character_data.direction," scale.x：",character.scale.x)


# ==========================================
# —— 安全的对外输入接口（AI逻辑） ——
# ==========================================

func set_current_state(v:State):
	if v!=current_state:
		current_state=v

func move_ai(p_velocity: Vector2) -> void:
	character.velocity = lerp(character.velocity, p_velocity, 0.2)
	character.move_and_slide()
