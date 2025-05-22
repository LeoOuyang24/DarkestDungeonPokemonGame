class_name GenericAttack extends Move

#very generic attack

func _init(name:String,targets:int,cd:int,summary_:String):
	super(name,targets,cd)
	summary = summary_

func getModifiers(user:Creature) -> Array:
	return [{"value":getDamage(user) if user else 1,"color":Color.RED,"calc": str(getMult()) + "x"}]
	#return [MoveButton.getCreatureStatUI(user,Creature.STATS.ATTACK)]


#return a multiple of the creature's attack to use
func getMult() -> float:
	return 1.0

func getDamage(c:Creature) -> int:
	if c:
		return getMult()*c.stats.getCurStat(CreatureStats.STATS.ATTACK)
	return 0

#anything else you want to do
func extras(user:Creature,target:Creature,battlefield:Battlefield):
	pass
	
func move(user:Creature, enemies:Array, battlefield):
	for i in enemies:
		var target:Creature = battlefield.getCreature(i)
		if target:
			battlefield.events.attack(user,target,getDamage(user),self)
			extras(user,target,battlefield)
