class_name Bleed extends StatusEffect


func _init():
	super("Bleed",load("res://sprites/statuses/bleed.png"),"Creature suffers 1 damage at the start of turn")
		
func endTurn() -> void:
	self.creature.stats.getStatObj(CreatureStats.STATS.HEALTH).addStat(-getStacks());
	super()
