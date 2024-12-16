class_name Small extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Small"
	tooltip="Creature speed is increased by 20% but health and attack is reduced by 10%."
		
func onAdd(c:Creature) -> void:
	c.stats.getStatObj(CreatureStats.STATS.HEALTH).modBaseStat(.9,false,self)
	c.stats.getStatObj(CreatureStats.STATS.SPEED).modBaseStat(1.2,false,self)
	c.stats.getStatObj(CreatureStats.STATS.ATTACK).modBaseStat(.9,false,self)
	
	super.onAdd(c)

func onRemove() -> void:
	creature.stats.getStatObj(CreatureStats.STATS.HEALTH).removeSource(self)
	creature.stats.getStatObj(CreatureStats.STATS.SPEED).removeSource(self)
	creature.stats.getStatObj(CreatureStats.STATS.ATTACK).removeSource(self)
	
func onAddUI(slot:Control) -> void:
	Resources.resize(slot.size*.5,slot)
	
func onRemoveUI(slot:Control) -> void:
	Resources.resize(slot.size*2,slot)
	
