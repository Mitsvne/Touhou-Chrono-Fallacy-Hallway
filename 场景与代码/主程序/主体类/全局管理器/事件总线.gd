extends Node

@warning_ignore_start("unused_signal")

##-----------局外-------------
## 角色改变
signal character_changed(character_name: String)

##-----------局内-------------
## 关卡完成
signal level_complete(level_id:String,stars: int)
## 角色死亡
signal character_dead(character_name: String)
## 开场开始
signal opening_started()
## 开场结束
signal opening_ended()

@warning_ignore_restore("unused_signal")
