class_name Bruised extends StatusEffect

func _init():
	super("Bruised",load("res://sprites/statuses/vulnerable.png"),"Creature takes 1.2x damage from physical damage.")

func onAdd(creature:Creature) -> void:
	super(creature)
	if creature:
		creature.stats.addDamageMod(1.2,false,self)
	
func onRemove() -> void:
	if self.creature:
		creature.stats.removeDamageMod(self)
