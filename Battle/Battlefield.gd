class_name Battlefield extends Node

#general battle logic

#index of the current player creature we are choosing moves for
#-1 if all creatures have selected a move
var currentCreature:Creature = null;

const maxAllies:int = Player.MAX_TEAM_SIZE + 1;
const maxEnemies:int = 3;

#the list of creatures
#the way this is set up is a bit weird but intentional. The idea is that lower index = closer to the front
#as a result, the format is frontMost ally -> backMost ally -> frontMost enemy -> backMost enemy
var creatures:Array = []

#actual number of non-null creatures
var creaturesNum:int = 0

var moveQueue:MoveQueue = MoveQueue.new();

#emitted when a NEW record is added to the queue, NOT when a record is updated 
#(ie, a move is selected for a creature(
signal add_move_queue(record:Move.MoveRecord, index:int);
#emitted when the queue order changes, emits the new queue for copying
signal queue_order_changed(data:Array);
#emitted when a record is popped, basically when a move is run
signal pop_move_queue(record:Move.MoveRecord);

signal new_current_creature(creature:Creature)
signal new_turn(); #new turn

#emitted when creature order changes
signal creature_order_changed(creature:Creature, oldIndex:int, newIndex:int)
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

func getCurrentCreature() -> Creature:
	return currentCreature

func setCurrentCreature(creature:Creature) -> void:
	currentCreature = creature

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
			new_turn.connect(creature.statuses.newTurn)
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
		moveQueue.removeUser(creature)
		creature_removed.emit(creature)
		
#very simply sets index to be the creature
#it is expected that if a creature displaces a preexisting creature, it is not removed and 
#is readded later
func moveCreature(creature:Creature, index:int):
	if creatures[index] != creature:
		creatures[index] = creature;
		creature_order_changed.emit();
			
#return allies based on if the creature is friendly or not
func getAllies(isFriendly:bool = true):
	if isFriendly:
		var allies = []
		for i in range(maxAllies):
			allies.push_back(creatures[i])
		return allies
	else:
		return getEnemies(true)
	
func getEnemies(isFriendly:bool = true):
	if isFriendly:
		var enemies = []
		for i in range(maxAllies,creatures.size(),1):
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
			moveQueue.addMove(creature,Creature.AI(creature,getEnemies(),getAllies()))

func newTurn() -> void:
	new_turn.emit(); #emit first to trigger any on-new-turn effects
	moveQueue.clear()
	for creature in creatures:
		if creature:
			moveQueue.insert(Move.MoveRecord.new(creature,null,[]))
	getEnemyMoves();
	if creaturesNum > 0:
		setCurrentCreature(getFrontMostCreatures(1,false,false)[0])


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
		queue_order_changed.emit(creature,moveQueue.getSpotInQueue(creature),moveQueue.updateSpot(creature));
		
	
#add a move to the move queue
func addMoveToQueue(record:Move.MoveRecord) -> void:
	if record.user:
		#if creature is already in queue, update what move it's gonna do
		#this avoids a sort
		if moveQueue.getSpotInQueue(record.user) != -1:
			moveQueue.addMove(record.user,record)
		else:
			moveQueue.insert(record)

#remove and return the topmost move
func top() -> Move.MoveRecord:
	var top = moveQueue.top()
	if top:
		return top;
	return null
	
func pop() -> Move.MoveRecord:
	var result = moveQueue.top()
	if result:
		#moveQueue.increment()
		moveQueue.removeUser(result.user)
		pop_move_queue.emit(result);
	return result
#returns whether all players have selected a move
func allMovesProcessed() -> bool:
	return currentCreature == null

func handlePlayerMove(record:Move.MoveRecord) -> void:
	addMoveToQueue(record)
	#whether or not theres another ally that hasn't taken a turn yet
	var newCurrent = null
	for i in range(0,maxAllies):
		if creatures[i] && !moveQueue.hasMove(creatures[i]):
			newCurrent = creatures[i];
			break
	setCurrentCreature(newCurrent)
		

func reset():
	for i in range(creatures.size()):
		removeCreature(getCreature(i))


