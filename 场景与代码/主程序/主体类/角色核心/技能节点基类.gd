extends Node
## 技能节点基类 —— 一个节点 = 一个技能的完整生命周期
class_name SkillNode

signal finished
signal interrupted

## 是否可被其他技能打断
@export var interruptible: bool = true
## 技能动画名（角色 AnimationPlayer 中对应的轨道名）
@export var anim_name: String = ""

## 由 SkillHost 注入的引用
var anplayer: AnimationPlayer
var agent: CharacterBody2D
var character_data: Character_Data
var character_ctrler: Character_Ctrler
var effect_ctrler: Effect_Ctrler

func execute() -> void:
	finished.emit()

func abort() -> void:
	interrupted.emit()
