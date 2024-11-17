class_name Stat extends Object

#signal emitted when our stat changes, with the amount it changed by and the new value
signal stat_changed(amount, newVal)

#class that represents a single base creature stat

var rootStat:int = 0 #the stat at level 1
var baseStat:int = 0 #the stat outside of in-battle modifiers
var curStat:int = 0 #the stat currently, since this may be modified in-battle

var bigBoosts:int = 0 #the number of big boosts this stat has

const BIG_BOOST_AMOUNT:int = 5 #the amount to increase this stat by per big boost
const PER_LEVEL_AMOUNT:int = 1 #amount to increase this stat by per level

var curMods:StatModTracker = StatModTracker.new() #mods for curstat
var baseMods:StatModTracker = StatModTracker.new() #mods for baseStat

var canBeLowered:bool = true; #true if stat can be lowered
var canBeRaised:bool = true; #true if stat can be raised

func _init(baseVal:int, levels:int = 1,bigBoosts:int = 0) -> void:
	rootStat = baseVal
	baseStat = predictBaseStat(rootStat,levels,bigBoosts)
	curStat = getBaseStat()
	
func _to_string():
	return str(getStat());

#calculate the base stat amount given how many levels we have
static func predictBaseStat(rootStat:int, levels:int, bigBoosts:int) -> int:
	return rootStat + bigBoosts*BIG_BOOST_AMOUNT + (levels-1)*perLevelIncrease(rootStat)
	
#in case in the future I decide to change how stats increase per level, this function offers
#that functionality
static func perLevelIncrease(baseStat:int) -> int:
	return PER_LEVEL_AMOUNT;
	
func getBaseStat():
	return baseMods.getValue(baseStat,canBeLowered,canBeRaised)
	
func getStat() -> int:
	return curMods.getValue(curStat,canBeLowered,canBeRaised)
	
func addBigBoost(amount:int = 1):
	bigBoosts += amount
	modBaseStat(BIG_BOOST_AMOUNT*amount)
	
#pass in an amount to modify, whether or not it's additive or multiplicative, and a source
func modBaseStat(amount:float,add:bool = true, source:Variant = self) -> void: 
	if source == self: #if the source is set as self, then it's probably part of leveling up or big boost
		if add:
			baseStat += amount #no real reason to track something like that, in fact we kind of already do
		else:
			baseStat *= amount
	else:
		if add:
			baseMods.addAdd(amount,source)
		else:
			baseMods.multMult(amount,source)
	modStat(amount, add, source)

#change our stat	
func modStat(amount:float, add:bool = true, source:Variant = self) -> void:
	if source == self:
		if add:
			curStat += amount
		else:
			curStat *= amount
	else:
		if add:
			curMods.addAdd(amount,source)
		else:
			curMods.multMult(amount,source)
	stat_changed.emit(amount, curMods.getValue(self.curStat))
	
func removeSource(source:Variant) -> void:
	if source != self:
		
		baseMods.removeSource(source)
		
		var oldAmount := curMods.getValue(self.curStat)
		curMods.removeSource(source)
		var newAmount := curMods.getValue(self.curStat)
		stat_changed.emit(newAmount - oldAmount, self.curStat)

func setCanBeLowered(val:bool) -> void:
	canBeLowered = val;
	
func setCanBeRaised(val:bool) -> void:
	canBeRaised = val;
