class_name Draggable extends Node

#component that makes parent draggable

var isDragging := false

func _input(e):
	var parent := get_parent()
	if parent:
		if e is InputEventMouseMotion \
		and parent.get_global_rect().has_point(e.position)\
		and Input.is_mouse_button_pressed( MOUSE_BUTTON_LEFT)\
		and !e.relative.is_zero_approx():
			isDragging = true
			parent.set_global_position(e.position - parent.get_rect().size/2)
		print("ASDF")
		for i in DragReceiver.DragReceivers:
			if i and i.get_parent() \
			and i.get_parent().get_global_rect().intersects(parent.get_global_rect()):
				i.drag_received.emit(self)
