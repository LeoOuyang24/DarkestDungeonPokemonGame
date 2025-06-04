class_name Poison extends StatusEffect

# a status effect that does damage equal to its stacks and increases by one stack each turn

func _init():
	super("Poison",load("res://sprites/statuses/poison.png"),"Creature suffers 1 damage at start of turn, increases by 1 every turn")
		
func endTurn() -> void:
	self.creature.stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(-getStacks());
	addStacks(1);
