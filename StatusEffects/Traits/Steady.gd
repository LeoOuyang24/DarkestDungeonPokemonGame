class_name Steady extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Steady"
		
func onAdd(c:Creature) -> void:
	c.stats.getStatObj(CreatureStats.STATS.ATTACK).setCanBeLowered(false);
	c.stats.getStatObj(CreatureStats.STATS.ATTACK).setCanBeRaised(false);
	
	super.onAdd(c)

#note: if there are every multiple sources of canBeLowered/raised, this will override one another
func onRemove() -> void:
	creature.stats.getStatObj(CreatureStats.STATS.ATTACK).setCanBeLowered(true);
	creature.stats.getStatObj(CreatureStats.STATS.ATTACK).setCanBeRaised(true);
	
