extends BTAction
## 黑板中代表角色的变量名（默认 "actor"）
@export var actor_var: String = "character"
## 黑板中代表 AnimationPlayer 的变量名（默认 "animation_player"）。如果为空则尝试从 actor 的子节点获取。
@export var animation_player_var: String = "anplayer"
@export var a: String = "character_data"
# ========== 移动参数 ==========
@export var speed: float = 120.0         ## 移动速度
@export var duration: float = 2.0        ## 每次移动持续时间（秒）
@export var angle_range: float = 360.0   ## 随机角度范围（360=全方位，180=前方半圆）

# ========== 动画参数 ==========
## 角色“前方”的世界方向。例：面朝左时设为 Vector2.LEFT
@export var forward_direction: Vector2 = Vector2.LEFT
@export var anim_forward: String = "前进"   ## 前进动画名
@export var anim_backward: String = "后退"  ## 后退动画名

# ========== 内部状态 ==========
var _timer: float = 0.0
var _direction: Vector2 = Vector2.ZERO
var _actor: CharacterBody2D = null
var _animation_player: AnimationPlayer = null
var _last_anim: String = ""

func _enter() -> void:
	
	# 获取 Actor
	
	_actor = blackboard.get_var(actor_var, null) as CharacterBody2D
	if not _actor:
		printerr("WanderRandomAnim: 黑板中没有找到 '", actor_var, "' 节点！")
		#return FAILURE

	# 获取 AnimationPlayer
	if animation_player_var:
		_animation_player = blackboard.get_var(animation_player_var, null) as AnimationPlayer
	if not _animation_player and _actor:
		_animation_player = _actor.get_node_or_null("AnimationPlayer")
	if not _animation_player:
		printerr("WanderRandomAnim: 未找到 AnimationPlayer！")

	_timer = 0.0
	_pick_random_direction()
	_play_appropriate_animation()


func _exit() -> void:
	if _actor:
		_actor.velocity = Vector2.ZERO
	_actor = null
	_animation_player = null


func _tick(p_delta: float) -> int:
	if not _actor:
		return FAILURE

	_timer += p_delta
	if _timer >= duration:
		if _actor:
			_actor.velocity = Vector2.ZERO
		return SUCCESS

	# 驱动移动
	_actor.velocity = _direction * speed
	_actor.move_and_slide()
	return RUNNING


func _pick_random_direction() -> void:
	var angle = deg_to_rad(randf_range(-angle_range / 2.0, angle_range / 2.0))
	_direction = Vector2.RIGHT.rotated(angle)


func _play_appropriate_animation() -> void:
	if not _animation_player:
		return

	# 点积判断：移动方向与前方方向夹角
	var dot = _direction.dot(forward_direction)
	var target_anim = ""
	if dot > 0.01:
		target_anim = anim_forward
	elif dot < -0.01:
		target_anim = anim_backward

	if target_anim and target_anim != _last_anim:
		if _animation_player.has_animation(target_anim):
			_animation_player.play(target_anim)
			_last_anim = target_anim
		else:
			printerr("WanderRandomAnim: 动画 '", target_anim, "' 不存在！")
