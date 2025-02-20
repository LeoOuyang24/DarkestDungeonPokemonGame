extends ShopItem
	
var move:Move = null:
	set(val):
		move = val
		self.call("set_texture_normal",move.icon)
		#set_texture_normal(move.icon)

func _init():
	needApplyItem = true
	needCreature = false
	super()

	
func getDescription() -> String:
	if !move:
		return ""
	return "Replace a move with " + move.getMoveName()

func onPurchase(c:Creature,m:int):
	c.setMove(move,m)
	
