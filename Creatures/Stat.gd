class_name Stat extends Object

#signal emitted when our stat changes, with the amount it changed by and the new value
signal stat_changed(amount, newVal)

#class that represents a single creature stat

var rootStat:int = 0 #the stat at level 1
var baseStat:int = 0 #the stat outside of in-battle modifiers
var curStat:int = 0 #the stat currently, since this may be modified in-battle

var bigBoosts:int = 0 #the number of big boosts this stat has

const BIG_BOOST_AMOUNT:int = 5 #the amount to increase this stat by per big boost
const PER_LEVEL_AMOUNT:int = 1 #amount to increase this stat by per level



func _init(baseVal:int) -> void:
	rootStat = baseVal
	baseStat = rootStat

#reset curStat to the base value
func resetStat(levels:int) -> void:
	curStat = getBaseStat()

#calculate the base stat amount given how many levels we have
static func predictBaseStat(rootStat:int, levels:int, bigBoosts:int) -> int:
	return rootStat + bigBoosts*BIG_BOOST_AMOUNT + (levels-1)*PER_LEVEL_AMOUNT
	
func getBaseStat():
	return baseStat
	
func getStat() -> int:
	return curStat
	
func addBigBoost(amount:int = 1):
	bigBoosts += amount
	addBaseStat(BIG_BOOST_AMOUNT*amount)
	
func addBaseStat(amount:int) -> void:
	baseStat += amount
	stat_changed.emit(amount,baseStat)

#change our stat	
func changeStat(newStat:int) -> void:
	var oldVal = self.curStat
	self.curStat = newStat
	
	stat_changed.emit(self.curStat - oldVal, self.curStat)
	
