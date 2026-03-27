extends CharacterBody2D
class_name Enemy
enum State{站立,攻击,受击,死亡}
@onready var an: AnimatedSprite2D = $图形/素材库
@onready var anplayer: AnimationPlayer = $动画
@onready var state_machine: StateMachine = $状态机
@onready var stats: Stats = $Stats
@onready var invincible_time: Timer = $受击无敌时间
@onready var tauchbox: CollisionShape2D = $碰撞面
@onready var hp_bar: HBoxContainer = $ui血条
var gravity:=ProjectSettings.get("physics/2d/default_gravity") as float
var pending_damage:Damage


func _ready() -> void:
	scale.x = -1
	
func tick_physics(state:State,delta: float) -> void:
	if invincible_time.time_left>0:
		an.modulate.a=sin(Time.get_ticks_msec())*0.5+0.5
	else:
		an.modulate.a=1
	match  state:
		State.站立,State.受击,State.死亡:
			velocity.y+=gravity*delta #重力

func get_next_state(state:State)->State:
	if stats.hp<=0:
		return State.死亡
	if pending_damage and invincible_time.time_left<0:
		return State.受击
	match state:
		State.站立:
			if stats.hp<=0:
				return State.死亡
			if pending_damage:
				return State.受击
			if Input.is_action_just_pressed("attack2p"):
				return State.攻击	
		State.受击:
			if not anplayer.is_playing():
				pending_damage=null
				return State.站立
		State.死亡:
			return State.死亡
		State.攻击:
			if not anplayer.is_playing():
				return State.站立
	return state
	


@warning_ignore("unused_parameter")
func transition_state(from:State,to:State):
	match to:
		State.站立:
			anplayer.play("站立")
		State.攻击:
			anplayer.play("攻击")	
		State.受击:
			anplayer.play("受击")
			stats.hp-=pending_damage.value
			invincible_time.start()
			print("沙包：被命中,当前生命值:",stats.hp)
		State.死亡:
			anplayer.play("死亡")
			tauchbox.disabled=true
			hp_bar.free()


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	if invincible_time.time_left>0:
		print("受击无敌")
		return
	pending_damage=Damage.new()
	pending_damage.value=20
	pending_damage.damage_owner=hitbox.owner
