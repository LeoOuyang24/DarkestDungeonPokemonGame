class_name AmorphStats extends CreatureStats

#stat object for the Masked, it's basically how it copies stats

 #creature that owns this
var owner:Creature = null

func getCurStat(stat:CreatureStats.STATS) -> int:
	#if getting attack or speed, get frontmost opponent's corresponding stat instead
	if stat == CreatureStats.STATS.ATTACK or stat == CreatureStats.STATS.SPEED:
		if GameState.getBattle() and GameState.getBattle().getEnemies(!owner.getIsFriendly()).size() > 0:
			var index = GameState.getBattle().getCreatureIndex(owner)
			if index != -1:
				var targets = GameState.getBattle().getFrontMostCreatures(index+1,owner.getIsFriendly(),false)
				var frontMost:Creature = targets[max(targets.size() - 1,index)] #creature we are copying from
				if frontMost.stats is AmorphStats: #to prevent infinite recursion, if the stat we are copying is another MaskedStat, return its base stats
					return frontMost.stats.getBaseStat(stat)
				else:
					return frontMost.stats.getCurStat(stat)
	return super(stat)
