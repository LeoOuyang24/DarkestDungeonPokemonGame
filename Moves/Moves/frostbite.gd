class_name Frostbite extends GenericAttack

# Called when the node enters the scene tree for the first time.
func _init():
	super("Frostbite",0,1,"Deal .75x damage to frontmost target and an additional .1x for each stack of Frost.")

func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(1,user.getIsFriendly())
	
func getMult():
	return .75
	
func move(user:Creature, targets:Array, battle:Battlefield):
	if user and battle and targets.size() > 0:
		var target:Creature = battle.getCreature(targets[0])
		if target:
			var damage = getDamage(user);
			
			var frost := target.statuses.getStatus("Frost")
			damage += .1*user.stats.getCurStat(CreatureStats.STATS.ATTACK)*frost.getStacks() if frost else 0
			
			battle.events.attack(user,target,damage,self)
		
		
	
