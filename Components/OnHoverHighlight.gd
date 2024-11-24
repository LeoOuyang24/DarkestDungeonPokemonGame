class_name OnHoverHightlight extends Node

#component that highlights a parent node

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent() as Control
	if (parent and parent.get_material()):
		parent.mouse_entered.connect(highlight)
		parent.mouse_exited.connect(unlight)
	pass # Replace with function body.

func highlight():
	Resources.highlight(get_parent(),Color.YELLOW)

func unlight():
	Resources.highlight(get_parent(),Color(0,0,0,0))
