extends ProgressBar

var creature = null;
@onready var label = $Label;
# Called when the node enters the scene tree for the first time.
func _ready():
	set_min(0);
	pass # Replace with function body.


func setHealth(val:int):
	set_value(val)
	label.set_text("Health: " + str(get_value()));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
