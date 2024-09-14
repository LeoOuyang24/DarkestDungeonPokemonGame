class_name Execute extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Execute",1,10)
	summary = "Deal %s damage to a chosen target. Reset cooldown if the target dies."
	pass # Replace with function body.

func getModifiers(user:Creature) -> Array:
	return [{"value":2*user.stats.getCurStat(CreatureStats.STATS.ATTACK),"color":Color.RED,"calc":"2x"}]

func move(user:Creature, enemies:Array, battlefield:Battlefield) -> int:
	if len(enemies) > 0:
		var target = battlefield.getCreature(enemies[0])
		Creature.dealDamage(user,target,getModifiers(user)[0].value); 
		if !target.isAlive():
			return 1
	return baseCooldown	

#func doMove(user:Creature, targets:Array, battlefield:Battlefield) -> void:
	#move(user,targets,battlefield)
	#setCooldown(baseCooldown)
	#move_used.emit()

	
