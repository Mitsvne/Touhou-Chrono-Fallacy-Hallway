class_name CardEffect
extends Resource

## 钩子 1：关卡初始化时触发（用于修改角色基础属性，如移速、最大生命值）
func apply_passive(_player: CharacterBody2D) -> void:
	pass

## 钩子 2：当效果从角色身上移除时触发（用于清理属性加成，防止脱下卡牌后属性常驻）
func remove_passive(_player: CharacterBody2D) -> void:
	pass

## 钩子 3：当玩家每次发动攻击时触发（用于触发特殊弹幕、概率追加伤害等）
func on_player_attack(_player: CharacterBody2D, _weapon: Node2D) -> void:
	pass

## 钩子 4：当玩家成功命中敌人时触发（用于吸血、触发爆炸、给敌人上毒等），target 通常是受击的怪物节点
func on_hit_enemy(_player: CharacterBody2D, _target: Node2D, _damage: float) -> void:
	pass

## 钩子 5：当玩家自己受到伤害时触发（用于概率免伤、反弹伤害等）
func on_player_hurt(_player: CharacterBody2D, _damage_source: Node2D) -> void:
	pass
