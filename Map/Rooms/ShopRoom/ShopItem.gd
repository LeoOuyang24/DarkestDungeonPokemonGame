class_name ShopItem extends TextureButton

#base class for all shop items

var cost:int = 50; #cost

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.DNA_changed.connect(checkCost)
	pass # Replace with function body.

func getDescription() -> String:
	return "LEO!!! YOU FORGOT TO ADD A DESCRIPTION TO THIS ITEM!!!"

#check if we this item can still be afforded 
func checkCost(amount:int):
	if amount < cost:
		disable()
		
#disable purchase
func disable():
	set_disabled(true)
	#material.set_shader_parameter("disabled", 1.0)
		
#what to run when used on a creature
func useOnCreature(creature:Creature) -> void:
	pass

func applyCost() -> void:
	GameState.setDNA(GameState.getDNA() - cost)

#what to run when purchased
#override in children classes
func onPurchase():
	applyCost();
	pass
	
#check if price works
#do not override
func _pressed():
	if GameState.getDNA() >= cost:
		onPurchase();
		
