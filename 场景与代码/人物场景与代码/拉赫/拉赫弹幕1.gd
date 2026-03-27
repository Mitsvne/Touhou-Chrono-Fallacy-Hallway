extends Area2D
var velocity = Vector2.RIGHT * 800 # 初始速度
var ishit=false
var team:String
@onready var an: AnimationPlayer = $动画

func _ready():
	pass

func _physics_process(delta):
	if(not ishit):
		position += velocity * delta
	# 超出屏幕时删除自身
	var view_rect = get_viewport_rect()
	if position.x < -100 or position.x > view_rect.size.x + 100 or \
	   position.y < -100 or position.y > view_rect.size.y + 100:
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not area.is_in_group(team):
		#print("hit")
		ishit=true
		#an.play(&"hit")
		if not an.is_playing():
			queue_free()
