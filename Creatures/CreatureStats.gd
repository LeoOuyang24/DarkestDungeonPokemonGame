class_name CreatureStats extends Object

#handles creature stats


enum STATS
{
	HEALTH = 0,
	ATTACK,
	SPEED
}

signal took_damage(damage:Damage) 
signal stat_changed(stat:STATS,amount:int) #signal for when a stat changes with the type of stat and the amount it changed by

#maps STATS to a Stat object
var stats:Dictionary = {}

# #modifies the amount of damage is taken
#positive change decreases damage, negative increases
#map from DAMAGE_TYPE to StatModTracker of that damage type
#TRUE damage type modifiers affect ALL other damage types and are calculated last (might need to change this later becuase it's kind of confusing)
#so if there's a +5 and 1.2x fire damage modifier and a +3 and 1.8 true damage modifier the formula would be:
# 1.8*(1.2*(damage + 5) + 3)
var damageMods:Dictionary = {}

func addDamageMod(amount:float, add:bool, source:Variant, type:Damage.DAMAGE_TYPES = Damage.DAMAGE_TYPES.PHYSICAL) -> void:
	if add:
		damageMods[type].addAdd(amount,source)
	else:
		print(type,Damage.DAMAGE_TYPES.TRUE,damageMods)
		damageMods[type].multMult(amount,source)

func removeDamageMod(source:Variant,type:Damage.DAMAGE_TYPES = Damage.DAMAGE_TYPES.PHYSICAL) -> void:
	damageMods[type].removeSource(source)

#take damage
#return how much damage was actually dealt
func takeDamage(damage:Damage) -> int: 
	#first calculate only damage type specific damage
	var damageVal:int = damageMods[damage.type].getValue(-damage.damage)
	#then it gets put through all damage modifiers
	damageVal = damageMods[Damage.DAMAGE_TYPES.TRUE].getValue(damageVal)
	getStatObj(STATS.HEALTH).modStat(damageVal)
	
	took_damage.emit(Damage.new(damageVal,damage.type))

	return damageVal

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
	
	for type in Damage.DAMAGE_TYPES.keys():
		damageMods[Damage.DAMAGE_TYPES[type]] = StatModTracker.new()

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
		

func levelUp(amount:int) -> void:
	forEachStat(func(stat:STATS,statObj:Stat):
		statObj.modBaseStat(statObj.perLevelIncrease(statObj.getRootStat())*amount)
		)

func getCurStat(stat:STATS) -> int:
	return stats[stat].getStat()

func getBaseStat(stat:STATS) -> int:
	return stats[stat].getBaseStat()
	
func getStatObj(stat:STATS) -> Stat:
	return stats[stat]
