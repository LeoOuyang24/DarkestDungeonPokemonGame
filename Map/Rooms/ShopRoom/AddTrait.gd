extends ShopItemButton


@onready var SyringeColor := %Color
@export var testScript:GDScript = null
	
func _ready():
	if testScript:
		setTrait(testScript.new())
	
	var cost = get_node("CostComponent")# as CostComponent
	cost.onPurchase = func():
		print("Purchased")

	
func setColor(color:Color) -> void:
	SyringeColor.setColor(color)
	
func setTrait(t:Resource) -> void:
	t.onAddUI(self);

