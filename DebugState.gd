class_name DebugState extends Label

#debug stuff

static var isDebug := false #true if we are debugging

static func isDebugging() -> bool:
	return isDebug

func _ready():
	set_modulate(Color(0,0,0,0))

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSPACE and event.ctrl_pressed:
			isDebug = !isDebug
			
			set_text("DEBUG " + ("ON" if isDebug else "OFF"))
			var t := create_tween()
			set_modulate(Color(1,1,1,1))
			t.tween_property(self,"modulate",Color(0,0,0,0),1.0)
	
