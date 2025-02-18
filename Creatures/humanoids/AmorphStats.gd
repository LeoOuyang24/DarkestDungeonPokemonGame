class_name AmorphStats extends CreatureStats

#stat object for the Amorph, it's basically how it copies stats
#it will attempt to copy the stat of the corresponding enemy. This is based on how far forward the amorph is
#for example, if the amorph is 2nd from the front, it will copy the enemy that is 2nd from the front

 #creature that owns this
var owner:Creature = null

func getCurStat(stat:CreatureStats.STATS) -> int:
	#if getting attack or speed, get frontmost opponent's corresponding stat instead
	if stat == CreatureStats.STATS.ATTACK or stat == CreatureStats.STATS.SPEED:
		if GameState.getBattle() and GameState.getBattle().getEnemies(!owner.getIsFriendly()).size() > 0:
			var index = GameState.getBattle().getCreatureIndex(owner) #index of us, think of this as how far we are from the front
			if index != -1:
				var targets = GameState.getBattle().getFrontMostCreatures(index+1,owner.getIsFriendly(),false)
				#creature we are copying from
				# if there aren't enough creatures, copy as far back as possible
				# so if we're 3rd from the front but there are only 2 enemies
				# copy the backmost enemy
				var frontMost:Creature = targets[min(targets.size() - 1,index)] 
				if frontMost.stats is AmorphStats: #to prevent infinite recursion, if the stat we are copying is another MaskedStat, return its base stats
					return frontMost.stats.getBaseStat(stat)
				else:
					return frontMost.stats.getCurStat(stat)
	return super(stat)
