class_name Dazed extends StatusEffect


func _init():
	super("Dazed",load("res://sprites/statuses/stunned.png"),"Creature can not attack!")
		
func onAdd(creature:Creature):
	super(creature)
	if creature:
		creature.active += 1
	pass
	
func onRemove():
	if self.creature:
		creature.active -= 1
	
