class_name Battlefield extends Node

#general battle logic

#index of the current player creature we are choosing moves for
#null if we aren't showing player creature moves
var currentCreature = 0;

const maxAllies = 4;
const maxEnemies = 4;

var creatures = []
#map of each creature to the record of what move they are using
var movesSelected = {};

var moveQueue = MoveQueue.new();

signal creature_died(creature:Creature);
signal add_move_queue(record:MoveRecord, index:int);
signal remove_move_queue(record:MoveRecord);

enum BATTLE_STATES {
	PLAYER_TURN,
  	ENEMY_TURN,
	BATTLE
	}
	
enum BATTLE_OUTCOME{
	WON,
	LOST,
	TBD
}
	
@export var state = BATTLE_STATES.PLAYER_TURN;
var animeStart = -1; #the time we started with animations
# Called when the node enters the scene tree for the first time.


func _init():
	creatures.resize(maxAllies + maxEnemies)
	creatures.fill(null)

#return if battle is over
func isDone() -> BATTLE_OUTCOME:
	var found = false
	#check if all allies are dead
	for i in range(maxAllies):
		if creatures[i] != null:
			#there is at least one ally alive
			#no need to check the rest of the allies
			break
		if i == maxAllies-1:  #all allies are dead
			return BATTLE_OUTCOME.LOST
			
	for i in range(maxAllies,creatures.size()):
		if creatures[i] != null:
			#there is an enemy that is alive
			return BATTLE_OUTCOME.TBD;

	#no enemies alive
	return BATTLE_OUTCOME.WON

func getCurrentCreature():
	return getCreature(currentCreature)
	
func setState(state_):
	state = state_

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
		creatures[index] = creature;
		if creature:
			creature.isFriendly = (index < maxAllies)

#remove the creature, maybe remove it from the move queue
func removeCreature(creature:Creature, removeMoveToo:bool = true):
	for i in range(creatures.size()):
		if creatures[i] == creature:
			creatures[i] = null
			if removeMoveToo && movesSelected.get(creature):
				removeMoveFromQueue(movesSelected[creature]);
			return true;

func _ready():
	pass

#return allies based on if the creature is friendly or not
func getAllies(isFriendly:bool = true):
	if isFriendly:
		var allies = []
		for i in range(maxAllies - 1,-1,-1):
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

func newTurn():
	for i in range(maxAllies):
		if creatures[i]:
			currentCreature = i;
			break;
	clearMovesSelected()
	
	for i in range(maxAllies,creatures.size()):
		if creatures[i]:
			addMoveToQueue(Creature.AI(creatures[i],getEnemies(),getAllies()));

#check if any creatures have died between moves
#emitting a signal if yes
func checkForDeath():
	#I have to pass this in as an Array otherwise the lambda captures it by
	#value as opposed to by reference
	var found = false
	for i in range(creatures.size()):
		if (creatures[i] && !creatures[i].isAlive()):
			found = true
			creature_died.emit(creatures[i]);

	return found

func dealDamage(damage:int, target:Creature,attacker:Creature):
	# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
	target.takeDamage((attacker.getAttack()/target.getDefense())*damage);

#add a move to the move queue
func addMoveToQueue(record:MoveRecord):
	if record.user:
		#var preselected = record.move.getPreselectedTargets(allies,enemies); #get preselected targets and add them to our targets
		#record.targets.append_array(preselected)
		movesSelected[record.user] = record;
		#insert the move and emit signal of its index
		add_move_queue.emit(record,moveQueue.data.size() - moveQueue.insert(record));
		
func removeMoveFromQueue(record:MoveRecord):
	if movesSelected[record.user]:
		#slightly more efficient to pop if we can
		if record == moveQueue.top():
			moveQueue.pop();
		else:
			moveQueue.remove(record)
		movesSelected.erase(record.user)
		remove_move_queue.emit(record);

#remove the topmost move and return the next move 
func popAndTop():
	if moveQueue.top():
		removeMoveFromQueue(moveQueue.top())
		return moveQueue.topSequence();
	return null
#returns whether all players have selected a move
func allMovesProcessed():
	for i in getAllies():
		if i && !movesSelected.get(i):
			return false;
	return true;

func clearMovesSelected():
	movesSelected.clear();

func handlePlayerMove(user, move, targets):
	addMoveToQueue(MoveRecord.new(user,move,targets))
	#whether or not theres another ally that hasn't taken a turn yet

	for i in range(0,maxAllies):
		if creatures[i] && !movesSelected.get(creatures[i]):
			currentCreature = i;

func reset():
	for i in range(creatures.size()):
		creatures[i] = null


