extends CharacterState
## 冲刺 —— 消耗能量快速位移
class_name DashState


func enter(_prev: CharacterState = null) -> void:
	if machine and machine.character_main:
		machine.character_main.dash_animation()


func get_next_state() -> String:
	# 冲刺动画播放完毕 → 回到常态
	if machine and machine.anplayer and not machine.anplayer.is_playing():
		return "IdleState"
	return ""
