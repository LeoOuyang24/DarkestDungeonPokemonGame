class_name Grenade extends GenericAttack

func _init():
	super("Grenade",1,5,"Deal 1.5x damage to a creature and 1x damage to its neighbors")
	uses = 1
	pass # Replace with function body.

func getMult():
	return 1.5;

func move(user:Creature,targets:Array,battle:Battlefield):
	super(user,targets,battle)
	if targets.size() > 0 and user:
		var creature := battle.getCreature(targets[0])
		if creature:
			var neigh := battle.getNeighbors(creature)
			for i in neigh:
				battle.events.attack(user,i,user.stats.getCurStat(CreatureStats.STATS.ATTACK),self)
	
	
