class_name SingleHighlight extends Node

# a component that highlights a single control
#if another control with this component is clicked, the new control is highlighted
#and the old one is unhighlighted

static var current:SingleHighlight = null #the current to be highlighted

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent := get_parent() as Control
	if (parent and parent.get_material()):
		parent.pressed.connect(select)
	pass # Replace with function body.
	
#select this component
func select():
	current = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var parent := get_parent() as Control
	if current == self and parent and parent.get_material():
		Resources.highlight(parent,Color.YELLOW) 
