extends HBoxContainer

var dragging:Control = null
var draggingIndex:int = -1 #index of the control we're dragging
							#feel free to get rid of "dragging" and just use "draggingIndex" in the future

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:		
		if get_global_rect().has_point(event.position):	
			if event.pressed:
					for i in range(len(get_children())):
						var control := get_children()[i]
						if control.get_global_rect().has_point(event.position):
							dragging = control 
							draggingIndex = i
							break
			else:
				#once we have finished dragging a slot, update our team order
				dragging = null
				draggingIndex = -1
				GameState.PlayerState.updateTeam(get_children().map(func(butt):
					return butt.getCreature()
					))
			queue_sort()
				
	elif event is InputEventMouseMotion:
		if dragging:
			var j = 0
			dragging.position.x += event.screen_relative.x
			for i in range(len(get_children())):
				var control := get_children()[i]
				if (control.global_position.x > dragging.global_position.x and i < draggingIndex) or (control.global_position.x < dragging.global_position.x and i > draggingIndex):
					move_child(dragging,i)
					draggingIndex = i
					break
