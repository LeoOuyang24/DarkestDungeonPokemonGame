class_name Poison extends StatusEffect


func _init():
	super("Poison",load("res://sprites/statuses/poison.png"),"")
		
func newTurn() -> void:
	self.creature.stats.getStatObj(CreatureStats.STATS.HEALTH).addStat(-getStacks());
	addStacks(1);
