class_name Judgement extends Move
	
func _init():
	super("Judgement",1,1)
	summary ="Deal 1.5x damage to a creature. 0.5x damage if the target is not at full health"

func move(user:Creature,targets:Array,battle:Battlefield):
	if user and targets.size() > 0:
		var target = battle.getCreature(targets[0])
		if target:
			var mult := 1.5 if target.stats.getCurStat(CreatureStats.STATS.HEALTH) == target.stats.getBaseStat(CreatureStats.STATS.HEALTH)\
			else 0.5
			var damage := mult*user.stats.getCurStat(CreatureStats.STATS.ATTACK)
			battle.events.attack(user,target,damage,self)
		
		
		
