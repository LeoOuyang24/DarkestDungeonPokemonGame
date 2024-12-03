extends TextureRect

@onready var label := %RichTextLabel

var cost:int = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
	setCostLabel(cost)
	if get_parent_control():
		var rect := get_parent_control().get_global_rect()
		set_position(Vector2(0,.8*rect.size.y));
		
		#for child in get_parent_control().get_children():
			#if child is CostComponent:
				#setCost(child.cost)
				#break

func setCost(cost:int) -> void:
	self.cost = cost
	setCostLabel(cost)

func setCostLabel(cost:int):
	label.set_text(str(cost))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
