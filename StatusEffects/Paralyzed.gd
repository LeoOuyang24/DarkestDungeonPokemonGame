class_name Paralyzed extends StatusEffect

var resetVal:int = 0; #amount to add to speed after this status is lifted

func _init():
	super("Paralyzed",load("res://sprites/statuses/paralyzed.png"),"")
		
func onAdd(creature:Creature):
	super(creature)
	var stat = creature.stats.getStatObj(CreatureStats.STATS.SPEED)
	resetVal = stat.getStat()
	stat.setStat(0);
	
func onRemove():
	self.creature.stats.getStatObj(CreatureStats.STATS.SPEED).addStat(resetVal)
