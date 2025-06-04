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

var creature:Creature = null

#moves that we earn through leveling up. 
var levelUpMoves:Array=[]

#next move to learn
var levelUpMove:Move = null

#index of the next move in levelUpMoves we should learn
#another way to think of it is how many moves in levelUpMoves we've considered learning
var movesConsidered:int = 0

# Called when the node enters the scene tree for the first time.
func _init(c:Creature, pendingMoves_:Array = []):
	levelUpMoves = pendingMoves_
	creature = c
	pass # Replace with function body.

func levelUp(increaseLevel:int = 1) -> void:

	pendingBigBoosts += (increaseLevel + level%LEVELS_PER_BIG_BOOST)/LEVELS_PER_BIG_BOOST
	level += increaseLevel

	leveled_up.emit()
	
func getLevel() -> int:
	return level
	
#func getNextLevelUpMove() -> Move: #return the move at the front of pendingMoves, null if we are too low level
	#var movesLearned = getLevel()/(LEVELS_PER_NEW_MOVE) #how many moves we should've considered
	#if movesLearned > movesConsidered && movesConsidered < levelUpMoves.size():
		#return levelUpMoves[movesConsidered]
	#return null
#get a random move
#if creature is not null, will choose a move that this creature does not know
static func getRandomMove(creature:Creature = null) -> Move:
	var movesFolder := "res://Moves/Moves"
	var dir := DirAccess.open(movesFolder)
	if !dir:
		printerr("getNextLevelUpMove ERROR: " + error_string(DirAccess.get_open_error()))
	else:		
		var fileNames := dir.get_files()
		var blacklisted := [SwapPos.new(),PassTurn.new(),Scan.new(),Shoot.new()] #moves that can not be selected
		var move:Move = blacklisted[0]
		var counter = 100; #maximum searches
		#search until we find amove that is not in blacklisted or already learned
		while (blacklisted.reduce(func(accum:bool, blacklisted:Move):
			return accum or (move.getMoveName() == blacklisted.getMoveName())
			,false) or (creature and move in creature.getMoves())):
			var resource := load(movesFolder + "/" + fileNames[randi_range(0,fileNames.size() - 1)])
			if resource:
				move = resource.new()
			counter -= 1;				
			if counter <= 0:
				return Slash.new() #default to slash
		return move
	return null
	
#NEW: RETURN A RANDOM MOVE as opposed to a predetermined move
#super ass rn, just searches through the moves folder and looks for a random move
func getNextLevelUpMove() -> Move:
	var movesLearned = getLevel()/(LEVELS_PER_NEW_MOVE)
	if movesLearned > movesConsidered and !levelUpMove:
		levelUpMove = getRandomMove(creature)
	return levelUpMove
	
func appliedBigBoost(amount:int) -> void:
	pendingBigBoosts -= amount
	
func getPendingBigBoosts() -> int:
	return pendingBigBoosts
	
#called when a move has been considered
func moveConsidered() -> void:
	levelUpMove = null
	movesConsidered += 1
