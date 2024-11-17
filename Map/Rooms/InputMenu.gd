extends ColorRect

@onready var MessageBox := $Label

signal messages_empty #for when we run out of messages

var finished := true #true if not currently rendering a message
var messages := []
var tween = null
#set a message and play it 
func setMessage(message:String) -> void:
	finished = false;
	MessageBox.set_visible_characters(0);
	MessageBox.set_text(message);
	tween = create_tween()
	tween.tween_property(MessageBox,"visible_characters",message.length(),1);
	await tween.finished
	finished = true;
	
#add a message to be played
func pushMessage(message:String) -> void:
	messages.push_back(message)
	
func _input(event):
	if finished and messages.size() > 0 and event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT and event.is_pressed():
		setMessage(messages.pop_front())
		if messages.size() == 0:
			messages_empty.emit()
	#MessageBox.set_visible_characters((runtime)/(1000/CharPS))
	
func _process(delta):
	if tween:
		if Input.is_action_pressed("click"):
			tween.set_speed_scale(2);
		else:
			tween.set_speed_scale(1);
