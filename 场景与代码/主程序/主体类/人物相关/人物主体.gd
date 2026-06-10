extends Node
## 人物主体类，节点状态机驱动
class_name Character_Main

@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var character:CharacterBody2D
@export var anplayer: AnimationPlayer
@export var hurtbox: Hurtbox
@export var damage_number:PackedScene
@export var attack_bullet:PackedScene
@export var attack_effect:PackedScene

## 节点状态机 —— 编辑器中放置或代码自动创建
var state_machine: CharacterStateMachine = null

var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float
var current_velocity: Vector2 = Vector2.ZERO
var is_allow_key_move:bool=true
var is_alive:bool=true
var attack_timer = Timer.new()
var is_skill_timer_timeout:bool=true
var final_hit:bool=false

## 初始化函数
func _ready() -> void:
	await character.ready                          #等人物先加载
	character_data.direction_changed.connect(set_direction)
	character.scale.x = character_data.direction   #赋予初始朝向
	#普攻和技能cd计时器
	attack_timer.wait_time =  character_data.attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

	# 查找或创建状态机
	state_machine = _find_or_create_state_machine()
	if state_machine.get_parent() == null:
		add_child(state_machine)
	# 注入角色引用
	state_machine.character_main = self
	state_machine.character = character
	state_machine.character_data = character_data
	state_machine.character_ctrler = character_ctrler
	state_machine.anplayer = anplayer
	# 启动状态机
	state_machine.start("IdleState")

	print("4.Character_Main初始化完成:",character)

## 每帧效果函数
func _physics_process(delta: float) -> void:
	# 驱动状态机：死亡检测 → 状态转换 → 状态更新
	if state_machine:
		state_machine.physics_process(delta)

	if character_ctrler.is_gravity:
		current_velocity.y += gravity * delta

	is_allow_key_move=character_ctrler.get_is_key_moving()
	if is_allow_key_move and not is_dead() and not character_ctrler.get_is_moving():
		move(character_data.move_speed,delta)

## 查找编辑器中放置的状态机，没有则程序化创建
func _find_or_create_state_machine() -> CharacterStateMachine:
	for child in get_children():
		if child is CharacterStateMachine:
			return child
	# 兜底：代码创建
	var sm = PlayerStateMachine.new()
	sm.name = "StateMachine"
	return sm

## 惯性移动函数
func move(max_speed:float,delta):
	var input_dir = InputManager.get_vector("move_left", "move_right", "move_up", "move_down")
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

## 判断是否死亡
func is_dead():
	if character_data.hp<=0 or not is_alive:
		return true

## 普攻弹幕发射
func fire_bullet():
	if InputManager.is_action_pressed("attack") and character.has_method("normal_attack"):
		if attack_timer.is_stopped():
			attack_timer.start()
			character.normal_attack()

## 计时结束的回调函数
func _on_attack_timer_timeout():
	attack_timer.stop()

## 更新朝向：让人物始终盯着目标看
func update_direction():
	var target = character_ctrler.get_target()
	if not is_instance_valid(target):
		return
	var target_pos = target.global_position
	var self_pos = character.global_position
	# 计算目标在左还是在右
	var diff_x = target_pos.x - self_pos.x
	# 设置一个微小的死区（例如5像素），防止重合时疯狂转身
	if abs(diff_x) > 10.0:
		var new_dir = 1.0 if diff_x > 0 else -1.0
		character_data.direction = new_dir

## 设置朝向：处理视觉翻转和逻辑数值同步
func set_direction(_direct: float):
	# 统一翻转逻辑：保持原始缩放比例，只改变符号
	character.scale.x *= -1

## 移动动画播放函数
func move_animation():
	var dir:=InputManager.get_axis("move_left","move_right")
	if dir*character_data.direction>0:
		an_paly("前进")
	else:
		an_paly("后退")

## 冲刺动画播放函数
func dash_animation():
	var dir:=InputManager.get_axis("move_left","move_right")
	if dir*character_data.direction<0:
		if anplayer.has_animation("冲刺后"):
			an_paly("冲刺后")
		else:
			an_paly("冲刺")
	else:
		if anplayer.has_animation("冲刺前"):
			an_paly("冲刺前")
		else:
			an_paly("冲刺")

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
	if character_data.hp<=0 and not final_hit:
		final_hit=true
		attack_effect_position=hitbox.global_position
		attack_type=4
		hitstop=0.1
	get_tree().current_scene.add_child(damage_node)
	damage_node.set_damage(damage, character.position, Color.WHITE)
	get_tree().current_scene.add_child(attack_effect_node)
	if attack_effect_position != null:
		attack_effect_node.set_attack_effect(attack_type,attack_effect_position)
	else:
		attack_effect_node.set_attack_effect(attack_type,hitbox.global_position)
	attack_effect_node.set_hitstop(hitstop)
