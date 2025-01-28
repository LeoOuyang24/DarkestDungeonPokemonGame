class_name ShopItem extends CostButton

#base class for all shop items

func getDescription() -> String:
	return "LEO!!! YOU FORGOT TO ADD A DESCRIPTION TO THIS ITEM!!!"
		
#what to run when used on a creature
func useOnCreature(creature:Creature) -> void:
	pass


#what to run when purchased
#override in children classes
func onPurchase():
	pass
	
func _pressed():
	super()
	onPurchase()
