class_name AddArmorEffect extends StatusEffect

func _init():
	super("Armor",load("res://sprites/statuses/shield.png"),"")
		
func onAdd(creature:Creature) -> void:
	super(creature)
	self.creature.stats.addDamageMod(getStacks(),true,self)
	
func onRemove() -> void:
	self.creature.stats.removeDamageMod(self)
	
func newTurn() -> void:
	pass
