extends Node
## AI 人物主体 —— 轻量 FSM，BT 驱动或键盘调试两用
class_name Character_AI_Main

@export var character_data: Character_Data
@export var character_ctrler: Character_Ctrler
@export var character: CharacterBody2D
@export var anplayer: AnimationPlayer
@export var hurtbox: Hurtbox
@export var bt_player: BTPlayer
@export var skill_host: SkillHost
@export var ai_enabled: bool = true  # 编辑器总开关：关闭则始终走键盘调试模式
@export var damage_number: PackedScene
@export var attack_effect: PackedScene

enum State { NONE, 常态, 移动, 技能1, 技能2, 技能3, 技能4, 必杀, 死亡 }

var current_state: State = State.常态 :
	set(v):
		if current_state == v: return
		exit_state(current_state)
		transition_state(current_state, v)
		current_state = v
		enter_state(v)

var target: CharacterBody2D
var gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var current_velocity: Vector2 = Vector2.ZERO
var is_alive: bool = true

## 共用技能状态组
const SKILL_STATES = [State.技能1, State.技能2, State.技能3, State.技能4, State.必杀]


# ==========================================
# —— 生命周期 ——
# ==========================================

func _ready() -> void:
	await character.ready
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	character_data.direction_changed.connect(set_direction)
	character.scale.x = character_data.direction
	target = character_ctrler.get_target()
	print("4.Character_AI_Main初始化完成:", character)


func _physics_process(delta: float) -> void:
	# 死亡优先
	if is_dead():
		current_state = State.死亡
		return

	# AI 开关：ai_enabled(编辑器) AND 局内正常
	var should_bt_run := ai_enabled and GameStateManager.is_current_state(GameStateManager.STATE_PLAYING)
	if bt_player.active != should_bt_run:
		bt_player.active = should_bt_run
	# 双模式分流
	if bt_player.active:
		_process_bt(delta)
	else:
		_process_human(delta)

	# 状态效果
	tick_physics(current_state, delta)

	# 重力
	if character_ctrler.is_gravity:
		current_velocity.y += gravity * delta


# ==========================================
# —— BT 控制路径 ——
# ==========================================

func _process_bt(_delta: float) -> void:
	# 仅在正常状态运行 BT，其他状态（开场/暂停/结算）关闭
	if not GameStateManager.is_current_state(GameStateManager.STATE_PLAYING):
		bt_player.active = false
		return
	if not bt_player.active:
		bt_player.active = true  # 回到正常时自动激活

	# 自动 常态↔移动
	if current_state in [State.常态, State.移动]:
		if character.velocity.length() != 0:
			current_state = State.移动
		else:
			current_state = State.常态

	# 技能结束自动回常态
	_check_skill_finished()

	update_direction()


# ==========================================
# —— 测试键盘控制路径 ——
# ==========================================

func _process_human(delta: float) -> void:
	# 拔键 → 禁止键盘移动
	if not character_ctrler.get_is_key_moving():
		return
	# 惯性移动
	move(character_data.move_speed, delta)
	# 自动 常态↔移动
	if current_state in [State.常态, State.移动]:
		if _has_move_input():
			current_state = State.移动
		else:
			current_state = State.常态
	# 技能输入
	_handle_skill_input()
	# 技能结束自动回常态
	_check_skill_finished()
	update_direction()


func _has_move_input() -> bool:
	return InputManager.is_action_pressed("move_left_AI") or InputManager.is_action_pressed("move_right_AI")


func _handle_skill_input() -> void:
	if InputManager.is_action_just_pressed("skill1_AI"):
		current_state = State.技能1
	elif InputManager.is_action_just_pressed("skill2_AI"):
		current_state = State.技能2
	elif InputManager.is_action_just_pressed("skill3_AI"):
		current_state = State.技能3
	elif InputManager.is_action_just_pressed("skill4_AI"):
		current_state = State.技能4
	elif InputManager.is_action_just_pressed("ultimate_AI") and character_data.mp >= 100:
		current_state = State.必杀


# ==========================================
# —— 共用逻辑 ——
# ==========================================

## 技能动画播完自动回常态
func _check_skill_finished() -> void:
	if current_state in SKILL_STATES and skill_host.current_skill == null:
		current_state = State.常态


## 每帧状态效果
func tick_physics(state: State, _delta: float) -> void:
	match state:
		State.常态:
			update_direction()
		State.移动:
			move_animation()
		State.死亡:
			character_ctrler.set_invincible(true)
			character_ctrler.apply_gravity(true)
			is_alive = false
			bt_player.active = false


## 状态进入
func enter_state(state: State) -> void:
	match state:
		State.死亡:
			EventBus.character_dead.emit(character_data.team)


## 状态退出
func exit_state(_state: State) -> void:
	pass


## 技能名配置 —— 索引 0→技能1, 1→技能2, …, 4→必杀，每个角色在编辑器设
@export var skill_names: Array[String] = []

## 状态切换动画
func transition_state(_from: State, to: State) -> void:
	match to:
		State.常态:  an_paly("常态")
		State.移动:  move_animation()
		State.死亡:  an_paly("死亡")
		_:  # 技能状态 → 委托 SkillHost
			var idx = to - State.技能1
			if skill_host and idx >= 0 and idx < skill_names.size():
				skill_host.execute(skill_names[idx])


## 移动动画
func move_animation() -> void:
	var dir := character.velocity.x
	if dir * character_data.direction > 0:
		an_paly("前进")
	else:
		an_paly("后退")


func an_paly(an_name: String) -> void:
	if anplayer.has_animation(an_name):
		anplayer.play(an_name)
	else:
		printerr("缺失动画: ", an_name)


## 判断死亡
func is_dead() -> bool:
	return character_data.hp <= 0 or not is_alive


## 惯性移动（仅键盘测试用）
func move(max_speed: float, delta: float) -> void:
	var input_dir = InputManager.get_vector("move_left_AI", "move_right_AI", "move_up_AI", "move_down_AI")
	var target_direction = input_dir.normalized()
	if input_dir != Vector2.ZERO:
		if current_velocity.length() > 0.01:
			var dot = current_velocity.normalized().dot(target_direction)
			if dot < 0:
				current_velocity = Vector2.ZERO
		var target_velocity = target_direction * max_speed
		current_velocity = current_velocity.move_toward(target_velocity, character_data.acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, character_data.friction * delta)
	character.velocity = current_velocity
	character.move_and_slide()


## 朝向目标
func update_direction() -> void:
	if not is_instance_valid(target):
		return
	var diff_x = target.global_position.x - character.global_position.x
	if abs(diff_x) > 20.0:
		character_data.direction = 1.0 if diff_x > 0 else -1.0


func set_direction(_direct: float) -> void:
	character.scale.x *= -1


# ==========================================
# —— BT 任务接口 ——
# ==========================================

## BT 任务调用的状态切换
func set_current_state(v: State) -> void:
	current_state = v


## BT 任务调用的 AI 移动
func move_ai(p_velocity: Vector2) -> void:
	character.velocity = lerp(character.velocity, p_velocity, 0.2)
	character.move_and_slide()


# ==========================================
# —— 受击处理 ——
# ==========================================

func _on_hurtbox_hurt(hitbox: Variant, attack_data: AttackData) -> void:
	if not character_ctrler.get_is_allow_behit():
		return

	var damage: float = attack_data.damage
	var attack_type: int = attack_data.attack_type
	var hitstop: float = attack_data.hitstop
	var attack_effect_node = attack_effect.instantiate()
	var damage_node = damage_number.instantiate()
	var attack_effect_position: Vector2 = attack_effect_node.get_random_point_in_overlap(hitbox, hurtbox)

	if character_ctrler.get_is_allow_losehp():
		character_data.hp -= damage

	if character_data.hp <= 0:
		attack_effect_position = hitbox.global_position
		attack_type = 4
		hitstop = 0.15

	get_tree().current_scene.add_child(damage_node)
	damage_node.set_damage(damage, character.position, Color.WHITE)
	get_tree().current_scene.add_child(attack_effect_node)
	if attack_effect_position != null:
		attack_effect_node.set_attack_effect(attack_type, attack_effect_position)
	else:
		attack_effect_node.set_attack_effect(attack_type, hitbox.global_position)
	attack_effect_node.set_hitstop(hitstop)
