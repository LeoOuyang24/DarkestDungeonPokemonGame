class_name Small extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Small"
		
func onAdd(c:Creature) -> void:
	c.stats.getStatObj(CreatureStats.STATS.HEALTH).modBaseStat(.9,false,self)
	c.stats.getStatObj(CreatureStats.STATS.SPEED).modBaseStat(1.2,false,self)
	c.stats.getStatObj(CreatureStats.STATS.ATTACK).modBaseStat(.9,false,self)
	
	super.onAdd(c)

func onRemove() -> void:
	creature.stats.getStatObj(CreatureStats.STATS.HEALTH).removeSource(self)
	creature.stats.getStatObj(CreatureStats.STATS.SPEED).removeSource(self)
	creature.stats.getStatObj(CreatureStats.STATS.ATTACK).removeSource(self)
	
func onAddUI(slot:CreatureSlot) -> void:
	slot.setSize(slot.size*.5)
	
func onRemoveUI(slot:CreatureSlot) -> void:
	slot.setSize(slot.size*2)
	
