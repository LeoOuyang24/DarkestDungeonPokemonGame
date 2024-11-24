extends VBoxContainer

@onready var label := %RichTextLabel

var cost:int = 0;
var button:ShopItemButton = null

func setButton(butt:ShopItemButton) -> void:
	if button:
		remove_child(button)
	button = butt;
	add_child(button)
	move_child(button,0)
	
	button.size_flags_horizontal = (SIZE_SHRINK_CENTER)
	
	#label.set_text(button.cost)
	
func setCost(cost_:int) -> void:
	cost = cost_
	label.set_text(cost);
	
func _process(_delta):
	Resources.highlight(get_node("Item"),Color.YELLOW)
