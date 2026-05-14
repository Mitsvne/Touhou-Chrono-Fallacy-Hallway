@tool
extends BTAction

##动态获取场景中的第一个指定组成员
@export var group: StringName
@export var output_var: StringName = &"target"

func _generate_name() -> String:
	return "GetFirstNodeInGroup \"%s\"  ➜%s" % [
		group,
		LimboUtility.decorate_var(output_var)
		]

func _tick(_delta: float) -> Status:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	if nodes.size() == 0:
		return FAILURE
	blackboard.set_var(output_var, nodes[0])
	return SUCCESS
