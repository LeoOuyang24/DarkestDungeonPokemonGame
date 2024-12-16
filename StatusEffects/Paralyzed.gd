class_name Paralyzed extends StatusEffect

func _init():
	super("Paralyzed",load("res://sprites/statuses/paralyzed.png"),"Creature's speed is set to 0.")
		
func onAdd(creature:Creature):
	super(creature)
	var stat = creature.stats.getStatObj(CreatureStats.STATS.SPEED)
	stat.modStat(0,false,self)
	
func onRemove():
	self.creature.stats.getStatObj(CreatureStats.STATS.SPEED).removeSource(self)
