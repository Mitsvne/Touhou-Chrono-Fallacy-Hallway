extends Node
class_name Prop_Ctrler

@export var prop_data: Prop_Data
@export var prop: Area2D

var prop_owner: CharacterBody2D
var is_moving: bool = false          # 是否移动
var is_gravity: bool = false         # 是否受重力
var gravity: float = ProjectSettings.get("physics/2d/default_gravity")  # 重力数值
var x_max_speed: float = 9999.0      # x轴最大速度
var y_max_speed: float = 9999.0      # y轴最大速度
var current_velocity: Vector2 = Vector2.ZERO   # 当前速度
var current_drag: Vector2 = Vector2.ZERO       # 当前阻力/加速度

func _ready() -> void:
	prop_owner=prop_data.prop_owner
	set_process(false)

func _physics_process(delta: float) -> void:
	if not is_moving:
		set_process(false)
		return
	if not is_instance_valid(self) or not is_instance_valid(prop):
		stop_move()
		return
	if is_gravity:
		current_velocity.y += gravity * delta
	current_velocity = _update_velocity(current_velocity, current_drag, delta)
	current_velocity.x = clamp(current_velocity.x, -x_max_speed, x_max_speed)
	var world_velocity = Vector2(current_velocity.x * prop_data.prop_direction, current_velocity.y)
	if world_velocity.length() < 1:
		stop_move()
		return
	prop.position += world_velocity * delta

## 私有：根据阻力和加速度更新速度，drag为正数时是阻力，为负数时是加速度
func _update_velocity(velocity: Vector2, drag: Vector2, delta: float) -> Vector2:
	var new_vel = velocity
	if drag.x >= 0:
		new_vel.x = move_toward(new_vel.x, 0, drag.x * delta)
	else:
		if new_vel.x != 0:
			new_vel.x += sign(new_vel.x) * abs(drag.x) * delta
	if drag.y >= 0:
		new_vel.y = move_toward(new_vel.y, 0, drag.y * delta)
	else:
		if new_vel.y != 0:
			new_vel.y += sign(new_vel.y) * abs(drag.y) * delta
	return new_vel

## 开始移动函数
func start_move(initial_velocity: Vector2 = Vector2.ZERO, drag: Vector2 = Vector2.ZERO):
	if is_moving:
		return
	current_velocity = initial_velocity
	current_drag = drag
	is_moving = true
	set_process(true)

## 设置阻力/加速度函数
func set_drag(drag: Vector2):
	current_drag = drag

## 停止移动函数
func stop_move():
	if not is_moving:
		return
	is_moving = false
	set_process(false)
	current_drag = Vector2.ZERO
	current_velocity.x = 0
	if current_velocity.y < 0 and not is_gravity:
		current_velocity.y = 0

## 是否启动重力
func apply_gravity(value: bool):
	is_gravity = value

## 设置朝向（1=右，-1=左）
func set_direction(value: int):
	prop_data.bullet_direction = value

func get_target():
	var team = owner.team
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character is CharacterBody2D and not character.is_in_group(team):
			return character
	return null
	
func get_prop_owner():
	var team = owner.team
	var characters = get_tree().get_nodes_in_group("characters")
	for character in characters:
		if character is CharacterBody2D and character.is_in_group(team):
			return character
	return null
