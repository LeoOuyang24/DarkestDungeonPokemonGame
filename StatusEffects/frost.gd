class_name Frost extends StatusEffect

static var freezeAt:int = 10 #amount of stacks to freeze at

func _init():
	super("Frost",load("res://sprites/statuses/frost.png"),"All stacks are consumed at end of turn and creature.\
	Creature is slowed by amount equal to stacks or skips turn if stacks are %d or higher.",freezeAt)
		
func onAdd(creature:Creature) -> void:
	super(creature)
	#a bit redundant, but I found that the easiest way to ensure this works was to 
	#put all the funcionality in setStacks.
	setStacks(getStacks())

			
			
func setStacks(stack:int) -> void:
	super(stack)
	if creature:
		creature.stats.getStatObj(CreatureStats.STATS.SPEED).modStat(-getStacks(),true,self)
		if getStacks() >= freezeAt:
			creature.addActive(1)
		else:
			creature.addActive(-1)
		
func onRemove() -> void:
	if creature:
		creature.stats.getStatObj(CreatureStats.STATS.SPEED).removeSource(self)
		
func endTurn() -> void:
	setStacks(0)
