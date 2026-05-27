extends Node

@warning_ignore_start("unused_signal")
## 角色改变
signal character_changed(character_name: String)
## 关卡完成
signal level_complete(level_id:String,stars: int)
## 角色死亡
signal character_dead(character_name: String)

@warning_ignore_restore("unused_signal")
