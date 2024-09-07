class_name CreatureLevel extends Object

#handles leveling up

signal leveled_up()
signal big_boosted(amountLeft) #signal for when we big boost a stat, with the amount of boosts left emitted as well

var level:int = 1;
var pendingBigBoosts:int = 0

static var MAX_LEVEL = 100
const LEVELS_PER_BIG_BOOST:int = 3 #number of levels we have to level before getting a bigboost
const LEVELS_PER_NEW_MOVE:int = 5 #number of levels we have to level before getting a new move
const MAX_LEVELUP_MOVES:int = 10 #max number of moves we can learn via level up

#moves that we earn through leveling up. 
var levelUpMoves:Array=[]

#index of the next move in levelUpMoves we should learn
#another way to think of it is how many moves in levelUpMoves we've considered learning
var movesConsidered:int = 0

# Called when the node enters the scene tree for the first time.
func _init(pendingMoves_:Array = []):
	levelUpMoves = pendingMoves_
	pass # Replace with function body.

func levelUp() -> void:
	level += 1
	if (level%LEVELS_PER_BIG_BOOST == 0):
		pendingBigBoosts += 1
	
	leveled_up.emit()
	
func getLevel() -> int:
	return level
	
func getNextLevelUpMove() -> Move: #return the move at the front of pendingMoves, null if we are too low level
	var movesLearned = getLevel()/(LEVELS_PER_NEW_MOVE) #how many moves we should've considered
	if movesLearned > movesConsidered && movesConsidered < levelUpMoves.size():
		return levelUpMoves[movesConsidered]
	return null
	
func getPendingBigBoosts() -> int:
	return pendingBigBoosts
	
#called when a move has been considered
func moveConsidered() -> void:
	movesConsidered += 1

