extends PanelContainer

var clicked:bool = false

func _input(event):
	if event is InputEventMouseButton:
		if get_global_rect().has_point(event.position):
			pass
			
func _process( some_change ):
	#allow us to drag the control around
	#it wouldn't surprise me if there was a built-in way to do this already, but im too lazy to find it
	if clicked:
		set_global_position(get_global_mouse_position() - 0.5*size)
		clicked = false
	if Input.is_mouse_button_pressed( 1 ): # Left click
		if get_global_rect().has_point(get_global_mouse_position()):
			clicked = true
