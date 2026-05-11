extends Area2D

var ishit=false

@export var sprite: Sprite2D
@export var an: AnimationPlayer
@export var hitarea: CollisionShape2D
@export var hurtarea: CollisionShape2D
@export var bullet_data: Bullet_Data
@export var bullet_ctrler: Bullet_Ctrler
@export var effect_ctrler: Effect_Ctrler

func _ready():
	await get_tree().process_frame
	material_copy()
	bullet_ctrler.start_move_forward(600,-100)
	await get_tree().create_timer(3, false).timeout
	queue_free()

func _physics_process(_delta):
	if ishit:
		bullet_ctrler.stop_move()

## 命中效果
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.owner.is_in_group(bullet_data.bullet_team) and area.owner.is_in_group("characters"):
		ishit=true
		hitarea.set_deferred("disabled", true)
		hurtarea.set_deferred("disabled", true)
		animate_fill_from(sprite.material.get_shader_parameter("add"), 0.3)
		animate_fill_to(sprite.material.get_shader_parameter("sub"), 0.3)
		#await an.animation_finished
		await get_tree().create_timer(0.3).timeout
		queue_free()

## 被攻击命中效果
func _on_hurtbox_hurt(hitbox: Hitbox, attack_data: AttackData) -> void:
	if hitbox.owner.is_in_group("bullets"):
		bullet_data.bullet_hp-=attack_data.damage
		if bullet_data.bullet_hp<=0:
			ishit=true
			hitarea.set_deferred("disabled", true)
			hurtarea.set_deferred("disabled", true)
			animate_fill_from(sprite.material.get_shader_parameter("add"), 0.3)
			animate_fill_to(sprite.material.get_shader_parameter("sub"), 0.3)
			#await an.animation_finished
			queue_free()



## 着色器资源复制
func material_copy():
	sprite.material = sprite.material.duplicate()
	var mat = sprite.material as ShaderMaterial
	# 处理 add 纹理
	var add_original = mat.get_shader_parameter("add")
	if add_original is GradientTexture2D:
		var add_tex = add_original.duplicate()
		mat.set_shader_parameter("add", add_tex)
	# 处理 sub 纹理
	var sub_original = mat.get_shader_parameter("sub")
	if sub_original is GradientTexture2D:
		var sub_tex = sub_original.duplicate()
		mat.set_shader_parameter("sub", sub_tex)
	#print("材质ID：", sprite.material.get_instance_id())
	#print("add纹理ID：", sprite.material.get_shader_parameter("add").get_instance_id())
	#print("sub纹理ID：", sprite.material.get_shader_parameter("sub").get_instance_id())

## 着色器动画1
func animate_fill_from(tex: GradientTexture2D, duration: float = 1.5) -> Tween:
	var tween = create_tween()
	tween.tween_method(
		func(y: float):
			tex.fill_from = Vector2(1.0, y)
			tex.emit_changed()
			, 0.0, 1.0, duration
		)
	return tween

## 着色器动画2
func animate_fill_to(tex: GradientTexture2D, duration: float = 1.5) -> Tween:
	var tween = create_tween()
	tween.tween_method(
		func(y: float):
			tex.fill_to = Vector2(1.0, y)
			tex.emit_changed()
			, 0.0, 1.0, duration
	)
	return tween
