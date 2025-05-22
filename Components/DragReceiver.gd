class_name DragReceiver extends Node

signal drag_received(drag:Draggable)

#array of drag receivers currently in the tree
static var DragReceivers:Array = []

#a component that emits a signal when a Draggable component collides with it

func _ready():
	DragReceivers.push_back(self)

func _exit_tree() -> void:
	DragReceivers.erase(self)
