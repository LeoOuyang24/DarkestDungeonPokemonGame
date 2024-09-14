class_name Hamstring extends Move

# Called when the node enters the scene tree for the first time.
func _init():
	super("Hamstring",1,1)
	summary = "Deal %s damage to a chosen target and inflict 2 turns of paralysis"
	pass # Replace with function body.

func getModifiers(user:Creature) -> Array:
	return [{"value":0.75*user.stats.getCurStat(CreatureStats.STATS.ATTACK),"color":Color.RED,"calc":"0.75x"}]
	#return [MoveButton.getCreatureStatUI(user,Creature.STATS.ATTACK)]

func move(user:Creature, enemies:Array, battlefield):
	if len(enemies) > 0: 
		var target = battlefield.getCreature(enemies[0]);
		Creature.dealDamage(user,target,0.75*user.stats.getCurStat(CreatureStats.STATS.ATTACK)); 
		target.statuses.addStatus(Paralyzed.new(),2)
		

	
