class_name AddArmorEffect extends StatusEffect

func _init():
	super("Armor",load("res://sprites/statuses/shield.png"),"")
		
func onAdd(creature:Creature) -> void:
	super(creature)
	self.creature.stats.damageMods.addAdd(getStacks(),self)
	
func onRemove() -> void:
	self.creature.stats.damageMods.removeSource(self)
	
func newTurn() -> void:
	pass
