extends ShopItem


@onready var SyringeColor := %Color
	
var gene:Trait = null

func _init():
	needApplyItem = true
	super()
	
func setColor(color:Color) -> void:
	SyringeColor.setColor(color)
	
func setTrait(t:Resource) -> void:
	t.onAddUI(self);
	gene = t;
	
func getDescription() -> String:
	if !gene:
		return ""
	return "Add " + gene.getAdj() + " to a creature."

func onPurchase(c:Creature,_m):
	if c and gene:
		c.traits.addStatus(gene)
	
