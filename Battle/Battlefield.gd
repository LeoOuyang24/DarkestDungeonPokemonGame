class_name Battlefield extends Node

#general battle logic

#index of the current player creature we are choosing moves for
#-1 if all creatures have selected a move
var currentCreature:Creature = null;

const maxAllies = 5;
const maxEnemies = 4;

#the list of creatures
#the way this is set up is a bit weird but intentional. The idea is that lower index = closer to the front
#as a result, the format is frontMost ally -> backMost ally -> frontMost enemy -> backMost enemy
var creatures = []

#actual number of creatures
var creaturesNum = 0

var moveQueue:MoveQueue = MoveQueue.new();

signal creature_died(creature:Creature);
signal add_move_queue(record:Move.MoveRecord, index:int);
signal remove_move_queue(record:Move.MoveRecord);
signal new_current_creature(creature:Creature)
#emitted when a creature is added or removed
#"added" is true when a creature is added, false if removed
signal creature_order_changed(added:bool)
	
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

func getCurrentCreature():
	return currentCreature

func setCurrentCreature(creature:Creature):
	currentCreature = creature
	new_current_creature.emit(creature)

#true if creature is an ally
#false if creature is an enemy or doesn't exist
func isCreatureFriendly(creature:Creature):
	return getCreatureIndex(creature) < maxAllies

func getCreature(index:int):
	if index < 0 || index >= creatures.size():
		return null
	return creatures[index]

#get index of creature, -1 if can't be found
func getCreatureIndex(creature:Creature):
	for i in range(creatures.size()):
		if creatures[i] == creature:
			return i
				
	return -1;

#swap creatures at the two indicies
func swapCreature(index1:int, index2:int):
	var creature = getCreature(index2)
	addCreature(getCreature(index1),index2)
	addCreature(creature,index1)
	#print(allies)
	#addCreature(creature,index,isAlly)

func addCreature(creature:Creature, index:int):
	if index >= 0 && index < creatures.size():
		creaturesNum += int(creatures[index] == null) #if a previously empty spot, we have one more creature
		creatures[index] = creature;
		if creature:
			creature.isFriendly = (index < maxAllies)
		creature_order_changed.emit(true)

#remove the creature, maybe remove it from the move queue
func removeCreature(creature:Creature, removeMoveToo:bool = true):
	var index = getCreatureIndex(creature)
	if index != -1:
		creaturesNum -= int(creatures[index] != null)
		creatures[index] = null
		creature_order_changed.emit(false)
		if removeMoveToo:
			moveQueue.removeUser(creature)

func _ready():
	pass

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

func newTurn():
	var foundCurrent:bool = false
	for i in range(creatures.size()):
		if creatures[i]:
			creatures[i].tickMoves()
			#if a player creature, add an incomplete record to the queue
			#otherwise add the enemy's decision
			addMoveToQueue(Move.MoveRecord.new(creatures[i],null,[]) if creatures[i].getIsFriendly() else Creature.AI(creatures[i],getEnemies(),getAllies()));
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

func dealDamage(damage:int, target:Creature,attacker:Creature):
	# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
	target.takeDamage((attacker.getAttack()/target.getDefense())*damage);

#get full queue order of creatures
func getFullQueue() -> Array:
	return moveQueue.data
#add a move to the move queue
func addMoveToQueue(record:Move.MoveRecord):
	if record.user:

		var index = moveQueue.insert(record)
		#print(moveQueue.getSpotInQueue(record.user)) 
		add_move_queue.emit(moveQueue.data);
		
func removeMoveFromQueue(record:Move.MoveRecord):
	moveQueue.remove(record)
	remove_move_queue.emit(record);

#remove and return the topmost move
func popAndTop():
	var top = moveQueue.top()
	if top:
		removeMoveFromQueue(top)
		return top;
	return null
#returns whether all players have selected a move
func allMovesProcessed() -> bool:
	return currentCreature == null

func handlePlayerMove(user, move, targets):
	addMoveToQueue(Move.MoveRecord.new(user,move,targets))
	#whether or not theres another ally that hasn't taken a turn yet
	var newCurrent = null
	for i in range(0,maxAllies):
		if creatures[i] && !moveQueue.hasMove(creatures[i]):
			newCurrent = creatures[i];
			break
	setCurrentCreature(newCurrent)
		

func reset():
	for i in range(creatures.size()):
		creatures[i] = null


