extends ColorRect

@onready var MessageBox := $Label

#set a message and play it 
func setMessage(message:String) -> void:
	MessageBox.set_visible_characters(0);
	MessageBox.set_text(message);
	var tween = create_tween()
	tween.tween_property(MessageBox,"visible_characters",message.length(),1);
	await tween.finished
	#MessageBox.set_visible_characters((runtime)/(1000/CharPS))
