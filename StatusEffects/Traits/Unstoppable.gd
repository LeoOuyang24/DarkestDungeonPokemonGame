class_name Unstoppable extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Unstoppable"
	tooltip = "Creature's speed can't be lowered."
		
func onAdd(c:Creature) -> void:
	c.stats.getStatObj(CreatureStats.STATS.SPEED).setCanBeLowered(false);
	
	super.onAdd(c)

#note: if there are every multiple sources of canBeLowered/raised, this will override one another
func onRemove() -> void:
	creature.stats.getStatObj(CreatureStats.STATS.SPEED).setCanBeLowered(true);
	
