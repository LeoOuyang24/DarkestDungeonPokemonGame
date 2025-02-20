class_name ShopItem extends CostButton

#emitted to apply this item to a creature, 
#true if we target creatures, 
#false if we target moves
signal need_apply_item(needCreature:bool) 

var needApplyItem:bool = false #whether or not we need ApplyItem for this
var needCreature:bool = true

#base class for all shop items

func getDescription() -> String:
	return "LEO!!! YOU FORGOT TO ADD A DESCRIPTION TO THIS ITEM!!!"


#what to run when purchased
#override in children classes
#parameters are for potential targets, "i" is for the index of a move
#can be null
func onPurchase(c:Creature,i:int):
	pass
	
#how to use the item
#do not override
func applyItem(c:Creature,i:int):
	onPurchase(c,i)
	applyCost()
	
func _pressed():
	#if we need to select a target, emit the signal
	#applyItem will have to be called later from ShopRoom
	if needApplyItem:
		need_apply_item.emit(needCreature)
	else:
		applyItem(null,0)
