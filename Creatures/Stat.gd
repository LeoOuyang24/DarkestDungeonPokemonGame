class_name Stat extends Object

#signal emitted when our stat changes, with the amount it changed by and the new value
signal stat_changed(amount, newVal)

#class that represents a single creature stat

var rootStat:int = 0 #the stat at level 1
var curStat:int = 0 #the stat currently, since this may be modified in-battle

var bigBoosts:int = 0 #the number of big boosts this stat has

const BIG_BOOST_AMOUNT:int = 5 #the amount to increase this stat by per big boost
const PER_LEVEL_AMOUNT:int = 1 #amount to increase this stat by per level

func _init(baseVal:int) -> void:
	rootStat = baseVal

#reset curStat to the base value
func resetStat(levels:int) -> void:
	curStat = getBaseStat(levels)

#calculate the base stat amount given how many levels we have
func getBaseStat(levels:int) -> int:
	return rootStat + bigBoosts*BIG_BOOST_AMOUNT + (levels-1)*PER_LEVEL_AMOUNT
	
func getStat() -> int:
	return curStat

#change our stat	
func changeStat(newStat:int) -> void:
	var oldVal = self.curStat
	self.curStat = newStat
	
	stat_changed.emit(self.curStat - oldVal, self.curStat)
	
