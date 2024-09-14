class_name BleedingBlades extends Move

# Called when the node enters the scene tree for the first time.
func _init():
	super("Bleeding Blades",1,1)
	summary = "Deal %s damage to a chosen target and inflict 3 stacks of bleed."
	pass # Replace with function body.

func getModifiers(user:Creature) -> Array:
	return [{"value":user.stats.getCurStat(CreatureStats.STATS.ATTACK),"color":Color.RED,"calc":"1x"}]
	#return [MoveButton.getCreatureStatUI(user,Creature.STATS.ATTACK)]

func move(user:Creature, enemies:Array, battlefield):
	if len(enemies) > 0: 
		var target = battlefield.getCreature(enemies[0]);
		Creature.dealDamage(user,target,user.stats.getCurStat(CreatureStats.STATS.ATTACK)); 
		target.statuses.addStatus(Bleed.new(),3)
		

	
