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
