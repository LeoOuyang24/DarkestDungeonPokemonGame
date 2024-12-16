class_name RichButton extends BaseButton
#a button with a rich text label for its text

@onready var label:RichTextLabel = %RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func getText() -> String:
	return label.get_text()
	
func getLabel() -> RichTextLabel:
	return label
	
