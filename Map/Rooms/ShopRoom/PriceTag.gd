extends ColorRect

@onready var label := %RichTextLabel
var asdf = 5;
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent_control():
		var rect := get_parent_control().get_global_rect()
		set_position(Vector2(0,rect.size.y));
		
		for child in get_parent_control().get_children():
			if child is CostComponent:
				label.set_text(str(child.cost))
				break



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
