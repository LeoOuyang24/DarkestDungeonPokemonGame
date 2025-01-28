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

# #modifies the amount of damage is taken
#positive change decreases damage, negative increases
var damageMods:StatModTracker = StatModTracker.new()

func addDamageMod(amount:int, add:bool, source:Variant) -> void:
	if add:
		damageMods.addAdd(amount,source)
	else:
		damageMods.multMult(amount,source)

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
	
	stats[STATS.HEALTH].capped = true
	
	forEachStat(func(stat:STATS,statObj:Stat):
		statObj.stat_changed.connect(func(amount,newVal):
			stat_changed.emit(stat,amount)
			)	
		)

static func getStatName(stat:STATS) -> String:
	match stat:
		STATS.HEALTH: 
			return "Health"
		STATS.ATTACK:
			return "Attack"
		STATS.SPEED:
			return "Speed"
		_:
			return "getStatName: INVALID STAT"
			
static func getStatDescription(stat:STATS) -> String:
	match stat:
		STATS.HEALTH: 
			return "Creature dies if health reaches 0"
		STATS.ATTACK:
			return "Attack influences how much damage this creature does with attacks."
		STATS.SPEED:
			return "Creatures with higher speed move first."
		_:
			return "getStatDescription: INVALID STAT"
		

func levelUp() -> void:
	forEachStat(func(stat:STATS,statObj:Stat):
		statObj.modBaseStat(Stat.perLevelIncrease(statObj.getBaseStat()))
		)

func getCurStat(stat:STATS) -> int:
	return stats[stat].getStat()

func getBaseStat(stat:STATS) -> int:
	return stats[stat].getBaseStat()
	
func getStatObj(stat:STATS) -> Stat:
	return stats[stat]
