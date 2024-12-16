class_name Steadfast extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Steadfast"
	tooltip = "Creature's speed can't be changed."
		
func onAdd(c:Creature) -> void:
	c.stats.getStatObj(CreatureStats.STATS.SPEED).setCanBeLowered(false);
	c.stats.getStatObj(CreatureStats.STATS.SPEED).setCanBeRaised(false);
	
	super.onAdd(c)

#note: if there are every multiple sources of canBeLowered/raised, this will override one another
func onRemove() -> void:
	creature.stats.getStatObj(CreatureStats.STATS.SPEED).setCanBeLowered(true);
	creature.stats.getStatObj(CreatureStats.STATS.SPEED).setCanBeRaised(true);
	
