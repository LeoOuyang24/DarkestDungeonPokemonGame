extends ShopItem

signal need_apply_item() #emitted to apply this item to a creature

@onready var SyringeColor := %Color
	
var gene:Trait = null

	
func setColor(color:Color) -> void:
	SyringeColor.setColor(color)
	
func setTrait(t:Resource) -> void:
	t.onAddUI(self);
	gene = t;

func useOnCreature(creature:Creature) -> void:
	if gene:
		creature.traits.addStatus(gene)
		applyCost()

func getDescription() -> String:
	if !gene:
		return ""
	return "Add " + gene.getAdj() + " to a creature."

func onPurchase():
	need_apply_item.emit()
	
#probably not the best way to do this, but this overrides the default _pressed function in 
#CostButton, which makes it so that the cost is not applied immediately
#we want the cost to be applied when the trait is actually used, in case it's canceled
func _pressed():
	onPurchase()
