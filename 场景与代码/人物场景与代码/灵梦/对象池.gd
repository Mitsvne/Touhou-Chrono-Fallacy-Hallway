extends Node

# 子弹场景预加载
@export var bullet_scene: PackedScene
# 池子列表（存放已经回收的子弹）
var pool: Array = []
# 初始池大小
@export var initial_pool_size: int = 20
func _ready():
	# 预先创建一批子弹放入池中
	for i in range(initial_pool_size):
		var bullet = create_bullet()
		recycle_bullet(bullet)  # 创建后立刻回收，使其处于非活动状态

# 创建一个新子弹（不放入场景树）
func create_bullet():
	return bullet_scene.instantiate()

# 从池中获取一个子弹（如果池空则创建新子弹）
func get_bullet() -> Node:
	var bullet: Node
	if pool.size() > 0:
		bullet = pool.pop_back()
	else:
		bullet = create_bullet()
	# 将子弹添加到场景树中（需指定父节点）
	# 注意：父节点通常是一个专门的容器或当前场景
	# 这里假设调用者会负责添加，或者由池管理添加
	return bullet

# 回收子弹（移出场景树，放回池中）
func recycle_bullet(bullet: Node):
	# 断开所有可能残留的信号连接（可选，根据实际需求）
	# 例如：如果子弹有碰撞信号，建议在子弹脚本中统一断开
	# 这里仅做简单的位置重置和移除
	if bullet.is_inside_tree():
		bullet.get_parent().remove_child(bullet)
	# 重置子弹状态（位置、速度等）
	# 可以在子弹脚本中提供一个 reset() 方法，由这里调用
	pool.append(bullet)

# 可选：清空池子（场景切换时）
func clear_pool():
	for bullet in pool:
		bullet.queue_free()
	pool.clear()
