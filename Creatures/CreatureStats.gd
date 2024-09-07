class_name CreatureStats extends Object

#handles creature stats


enum STATS
{
	HEALTH = 0,
	ATTACK,
	SPEED
}

signal stat_changed(stat:STATS,amount:int) #signal for when a stat changes with the type of stat and the amount it changed by

#maps STATS to a Stat object
var stats:Dictionary = {}

#pass in a function that takes in a STATS and a Stat and runs it on each stat
func forEachStat(callable:Callable) -> void:
	for stat:STATS in stats:
		var statObj = stats[stat]
		callable.call(stat,statObj)

func _init(maxHealth:int, maxAttack:int, maxSpeed:int):
	stats = {
		STATS.HEALTH: Stat.new(maxHealth),
		STATS.ATTACK: Stat.new(maxAttack),
		STATS.SPEED: Stat.new(maxSpeed)
	}
	
	forEachStat(func(stat:STATS,statObj:Stat):
		statObj.stat_changed.connect(func(amount,newVal):
			stat_changed.emit(stat,amount)
			)	
		)

func levelUp() -> void:
	forEachStat(func(stat:STATS,statObj:Stat):
		statObj.addBaseStat(Stat.perLevelIncrease(statObj.getBaseStat()))
		)

func getCurStat(stat:STATS) -> int:
	return stats[stat].getStat()

func getBaseStat(stat:STATS) -> int:
	return stats[stat].getBaseStat()
	
func getStatObj(stat:STATS) -> Stat:
	return stats[stat]
