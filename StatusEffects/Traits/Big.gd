class_name Big extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Big"
		
func onAdd(c:Creature) -> void:
	c.stats.getStatObj(CreatureStats.STATS.HEALTH).modBaseStat(1.1,false,self)
	c.stats.getStatObj(CreatureStats.STATS.SPEED).modBaseStat(.9,false,self)
	c.stats.getStatObj(CreatureStats.STATS.ATTACK).modBaseStat(1.1,false,self)
	
	super.onAdd(c)

func onRemove() -> void:
	creature.stats.getStatObj(CreatureStats.STATS.HEALTH).removeSource(self)
	creature.stats.getStatObj(CreatureStats.STATS.SPEED).removeSource(self)
	creature.stats.getStatObj(CreatureStats.STATS.ATTACK).removeSource(self)
	
func onAddUI(slot:Control) -> void:
	Resources.resize(slot,slot.size*2)
	
func onRemoveUI(slot:Control) -> void:
	Resources.resize(slot,slot.size*.5)
	
