class_name ShopItemButton extends TextureButton

#represents a button that you'd find in a shop, used with ShopItem

var cost:int = 100; #cost

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.DNA_changed.connect(checkCost)
	pass # Replace with function body.

#check if we this item can still be afforded 
func checkCost(amount:int):
	if amount < cost:
		disable()
		
#disable purchase
func disable():
	set_disabled(true)
	#material.set_shader_parameter("disabled", 1.0)
		

#what to run when purchased
#override in children classes
func _onPurchase():
	pass
	
#check if price works
#do not override
func _pressed():
	if GameState.getDNA() >= cost:
		GameState.setDNA(GameState.getDNA() - cost)
		_onPurchase();
		
func _process(delta) -> void:
	Resources.highlight(self,Color.YELLOW if is_hovered() else Color(0,0,0,0))
