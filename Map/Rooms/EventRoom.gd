class_name EventRoom extends RoomBase

#a common starting ground for event rooms, where no combat happens

@onready var Menu := %InputMenu;
@onready var Background := %Background


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#runs a little intro
func playIntro(intro:String):
	var tween = create_tween()
	tween.tween_interval(1)
	tween.tween_property(Menu,"modulate",Color.WHITE,1);
	await tween.finished;
	tween.stop()
	await Menu.setMessage(intro);
	
func _on_button_pressed():
	room_finished.emit()
	pass # Replace with function body.
