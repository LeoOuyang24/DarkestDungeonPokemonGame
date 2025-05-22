class_name Execute extends GenericAttack


# Called when the node enters the scene tree for the first time.
func _init():
	super("Execute",1,10,"Deal 1.5x damage to a chosen target. Reset cooldown if the target dies.")
	pass # Replace with function body.

func getMult():
	return 1.5

func move(user:Creature, enemies:Array, battlefield:Battlefield) -> int:
	super(user,enemies,battlefield)
	if len(enemies) > 0:
		var target = battlefield.getCreature(enemies[0])
		if !target.isAlive():
			return 1
	return baseCooldown	



	
