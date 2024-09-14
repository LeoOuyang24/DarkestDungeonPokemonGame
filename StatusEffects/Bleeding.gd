class_name Bleed extends StatusEffect


func _init():
	super("Bleed",load("res://sprites/statuses/bleed.png"),"")
		
func newTurn() -> void:
	self.creature.stats.getStatObj(CreatureStats.STATS.HEALTH).addStat(-getStacks());
	super()
