class_name Battlefield extends Node

#general battle logic

const maxAllies:int = Player.MAX_TEAM_SIZE + 1;
const maxEnemies:int = 3;

#the list of creatures
#the way this is set up is a bit weird but intentional. The idea is that lower index = closer to the front
#as a result, the format is frontMost ally -> backMost ally -> frontMost enemy -> backMost enemy
var creatures:Array = []

#actual number of non-null creatures
var creaturesNum:int = 0

var moveQueue:MoveQueue = MoveQueue.new();

#emitted when a record is added/updated in moveQueue
signal add_move_queue(record:Move.MoveRecord);
#emitted when the queue order changes, emits the new queue for copying
signal queue_order_changed(data:Array);
#emitted when a record is popped, basically when a move is run
signal pop_move_queue(record:Move.MoveRecord);

signal new_current_creature(creature:Creature)

signal battle_ended();
signal new_turn(); #new turn
signal first_turn(); #first turn

#emitted when creature order changes
#this can be if a creature is moved or if a creature is removed/added
signal creature_order_changed()
signal creature_added(creature:Creature, index:int)
signal creature_removed(creature:Creature)
	
enum BATTLE_OUTCOME{
	WON,
	LOST,
	TBD
}

func _init():
	creatures.resize(maxAllies + maxEnemies)
	creatures.fill(null)
	
	#creature_added.connect(func(c,i):
		#creature_order_changed.emit()
		#)
		#
	#creature_removed.connect(func(c):
		#creature_order_changed.emit()
		#)
	

#return whether or not all enemies are dead
func isDone() -> bool:
	var enemies = getEnemies()
	for i in enemies:
		if i:
			return false
	return true

#this function converts relative to absolute
#friendly is "true" if "ind" is relative to allies, "false" if relative to enemies
static func relPosToAbs(ind:int, friendly:bool):
	return ind + int(!friendly)*maxAllies

func getCreature(index:int) -> Creature:
	if index < 0 || index >= creatures.size():
		return null
	return creatures[index]

#get index of creature, -1 if can't be found
func getCreatureIndex(creature:Creature) -> int:
	return creatures.find(creature)

#swap creatures at the two indicies
func swapCreature(index1:int, index2:int) -> void:
	var creature = getCreature(index2)
	#addCreature(getCreature(index1),index2)
	#addCreature(creature,index1)
	creatures[index2] = creatures[index1]
	creatures[index1] = creature
	creature_order_changed.emit();


#add a creature for the first time
#if creature is already in, you should use moveCreature
func addCreature(creature:Creature, index:int):
	if index >= 0 && index < creatures.size():
		creaturesNum += int(creatures[index] == null) #if a previously empty spot, we have one more creature
		creatures[index] = creature;
		if creature:
			creature.isFriendly = (index < maxAllies)
			new_turn.connect(creature.newTurn)
			first_turn.connect(creature.firstTurn.bind(self))
			#creature.traits.inBattle(self)
			creature.stats.stat_changed.connect(func(stat:CreatureStats.STATS,amount:int):
				if stat == CreatureStats.STATS.SPEED:
					updateMoveQueue(creature))
			moveQueue.insert(Move.MoveRecord.new(creature,null,[]))
			
			creature_added.emit(creature,index)
		

#remove the creature, and remove it from the move queue
func removeCreature(creature:Creature):
	var index = getCreatureIndex(creature)
	if index != -1:
		creaturesNum -= int(creatures[index] != null)
		creatures[index] = null
		moveQueue.remove(creature)
		creature_removed.emit(creature)
		
#very simply sets index to be the creature
#it is expected that if a creature displaces a preexisting creature, it is not removed and 
#is readded later
func moveCreature(creature:Creature, index:int):
	if creatures[index] != creature:
		creatures[index] = creature;
		creature_order_changed.emit();
			
#return allies based on if the creature is friendly or not
#getNull is whether or not we want null creatures too
#"index" is true if we want indicies rather than creatures
func getAllies(isFriendly:bool = true, getNull:bool = true, index:bool = false) -> Array:
	if isFriendly:
		var allies:Array = []
		for i in range(maxAllies):
			if creatures[i] or getNull:
				if index:
					allies.push_back(i)
				else:
					allies.push_back(creatures[i])
		return allies
	else:
		return getEnemies(true)
	
func getEnemies(isFriendly:bool = true, getNull:bool = true, index:bool = false) -> Array:
	if isFriendly:
		var enemies:Array = []
		for i in range(maxAllies,creatures.size(),1):
			if creatures[i] or getNull:
				if index:
					enemies.push_back(i)
				else:
					enemies.push_back(creatures[i])
		return enemies	
	else:
		return getAllies(true)

#get the frontmost creatures.
#if "enemies" is true, gets frontmost not-friendly creatures, other wise frontmost friendly creatures
#if "index" is true, returns the indicies rather than the creatures
#if "front" is negative, get's rearmost creatures instead
func getFrontMostCreatures(front:int = 1, enemies:bool = true, index:bool = true) -> Array:
	var arr = []
	var start = 0 if !enemies else maxAllies
	var end = maxAllies if !enemies else creatures.size()
	var iterate = range(start,end,1) if front > 0 else range(end-1,start-1,-1) #go backwards if negative, getting rearmost creatures
	for i in iterate:
		if abs(front) <= arr.size():
			break
		if creatures[i]:
			arr.push_back(creatures[i] if !index else i)
	return arr

func getEnemyMoves():
	for creature in getEnemies():
		if creature:
			addMoveToQueue(Creature.AI(creature,self))
			#moveQueue.addMove(creature,)

#given a user and a targeting criteria, returns all creatures that could potentially
#be targeted
func getLegalTargets(user:Creature, criteria:Move.TARGETING_CRITERIA) -> Array:
	var targetArray:Array = []
	match criteria:
		Move.TARGETING_CRITERIA.ONLY_ENEMIES:
			targetArray = getEnemies(user.getIsFriendly())
		Move.TARGETING_CRITERIA.ONLY_ALLIES:
			targetArray = getAllies(user.getIsFriendly())
		Move.TARGETING_CRITERIA.OTHER_ALLIES:
			targetArray.assign(getAllies(user.getIsFriendly()).map(func(asdf:Creature) -> Creature:
				return asdf if asdf != user else null
				) )
		Move.TARGETING_CRITERIA.ALL:
			targetArray = creatures
		Move.TARGETING_CRITERIA.ALL_OTHERS:
			targetArray = creatures.map(func(asdf:Creature):
				return asdf if asdf != user else null
				)
	#filter out null creatures
	return targetArray.filter(func(creature:Creature):
		return creature != null
		)
#given a move used by a creature, calculate the appropriate targets
#returns the indicies since that's what MoveRecord uses
func getTargets(user:Creature, move:Move) -> Array[int]:
	if move:
		var criteria = move.getTargetingCriteria()
		var targetArray := getLegalTargets(user,criteria)
		if targetArray.size() > 0:
			targetArray.shuffle()
			var arr:Array[int] = []
			#have to do this cringe ass .assign call because from what I can tell, .map will always return an untyped array
			#https://github.com/godotengine/godot/issues/72566
			arr.assign(targetArray.slice(0,min(move.getNumOfTargets(),targetArray.size())).map(func(creature):
				return getCreatureIndex(creature))) #get as many targets as possible	
			return arr

	return []	
			
#what to do at the start of every turn
#code that is common to firstTurn and newTurn
func startTurn() -> void:
	moveQueue.reset();
	for creature:Creature in creatures:
		moveQueue.insert(Move.MoveRecord.new(creature,null,[]))
	getEnemyMoves();

		
#what to run on the very first turn
func firstTurn() -> void:
	first_turn.emit();
	startTurn()
	
	
#what to run on every turn after the first
func newTurn() -> void:
	new_turn.emit(); #emit first to trigger any on-new-turn effects
	startTurn()

func onBattleEnd() -> void:
	for i in GameState.PlayerState.getTeam():
		if i:
			i.statuses.clear()

#returning the index of the first dead creature if any or -1 if none
func checkForDeath() -> int:
	#I have to pass this in as an Array otherwise the lambda captures it by
	#value as opposed to by reference
	var found = false
	for i in range(creatures.size()):
		if (creatures[i] && !creatures[i].isAlive()):
			return i
	return -1

#get full queue order of creatures
func getFullQueue() -> Array:
	return moveQueue.data
	
#update creature's spot in queue
func updateMoveQueue(creature:Creature) -> void:
	if creature:
		#print(moveQueue.find(creature)," ",moveQueue.updateSpot(creature))
		#print(moveQueue.data)
		queue_order_changed.emit(creature,moveQueue.find(creature),moveQueue.updateSpot(creature));
		
	
#add a move to the move queue
func addMoveToQueue(record:Move.MoveRecord) -> void:
	#if creature is already in queue, update what move it's gonna do
	if record:
		moveQueue.insert(record)
		add_move_queue.emit(record)


func getNextMove() -> Move.MoveRecord:
	return moveQueue.pop();
	
##just increments the queue
#func nextMove() -> void:
	#moveQueue.increment();

#add a record to queue, then return another creature that has not taken a turn yet
func handlePlayerMove(record:Move.MoveRecord) -> void :
	addMoveToQueue(record)

#returns the next creature with no move selected
func getCreatureWithNoRecord() -> Creature:
		#whether or not theres another ally that hasn't taken a turn yet
	for i in range(0,maxAllies):
		if creatures[i] && !moveQueue.hasMove(creatures[i]):
			return creatures[i];
	return null
		

func reset():
	for i in range(creatures.size()):
		removeCreature(getCreature(i))
