class_name Battlefield extends Node

#general battle logic

#index of the current player creature we are choosing moves for
#null if we aren't showing player creature moves
var currentCreature = 0;

const maxAllies = 4;
const maxEnemies = 4;

var allies = []
var enemies = []
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
	allies.resize(maxAllies)
	allies.fill(null)
	
	enemies.resize(maxEnemies);
	enemies.fill(null)
	
#give a Callable (Array,bool) -> bool that is then called on allies and enemies
#useful if you want to do something involving both
#the function should return true if we want to return early
func processAllCreatures(callable:Callable):
	if (!callable.call(allies,true)):
		callable.call(enemies,false)	

#return if battle is over
func isDone() -> BATTLE_OUTCOME:
	var found = false
	#check if all allies are dead
	for i in allies:
		if i != null:
			found = true;
			break;
			
	#didnt' find a single non-null ally, we lost!
	if !found:
		return BATTLE_OUTCOME.LOST;
	
	#otherwise, check if any enemies are alive
	for i in enemies:
		if i != null:
			return BATTLE_OUTCOME.TBD;
	return BATTLE_OUTCOME.WON;

func getCurrentCreature():
	if currentCreature < allies.size() && currentCreature>=0:
		return allies[currentCreature]
	return null;
	
func setState(state_):
	state = state_

#true if creature is an ally
#false if creature is an enemy or doesn't exist
func isCreatureFriendly(creature:Creature):
	for i in allies:
		if i == creature:
			return true
	return false

#get index of creature, -1 if can't be found
func getCreatureIndex(creature:Creature,isAlly:bool):
	if isAlly:
		for i in range(allies.size()):
			if creature == allies[i]:
				return i
	else:
		for i in range(enemies.size()):
			if creature == enemies[i]:
				return i
				
	return -1;

#move a creature to "index"
#this will override the prexisting creature
func moveCreature(creature:Creature,  index:int, isAlly:bool):
	removeCreature(creature,false)
	addCreature(creature,index,isAlly)
	#print(allies)
	#addCreature(creature,index,isAlly)

func addCreature(creature:Creature, index:int, isAlly:bool):
	var row = null; #array of creatures, either the enemies or allies
	var max = 0;
	if isAlly:
		row = allies;
		max = maxAllies;
	else:
		row = enemies;
		max = maxEnemies;
	
	if index >= 0 && index < max:
		row[index] = creature;
				
#remove the creature, maybe remove it from the move queue
func removeCreature(creature:Creature, removeMoveToo:bool = true):
	processAllCreatures(func(creatures, isAlly):
		for i in range(creatures.size()):
			if creatures[i] == creature:
				creatures[i] = null
				if removeMoveToo && movesSelected.get(creature):
					removeMoveFromQueue(movesSelected[creature]);
				return true;
		)

func _ready():
	pass

func newTurn():
	for i in range(allies.size()):
		if allies[i]:
			currentCreature = i;
			break;
	clearMovesSelected()
	
	for i in enemies:
		if i:
			addMoveToQueue(Creature.AI(i,enemies,allies));

#check if any creatures have died between moves
#emitting a signal if yes
func checkForDeath():
	#I have to pass this in as an Array otherwise the lambda captures it by
	#value as opposed to by reference
	var found = [false]
	var lambda = func(array,isAlly):
		for i in range(array.size()):
			if (array[i] && !array[i].isAlive()):
				found[0] = true
				creature_died.emit(array[i]);
	processAllCreatures(lambda)
	return found[0]

func dealDamage(damage:int, target:Creature,attacker:Creature):
	# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
	target.takeDamage((attacker.getAttack()/target.getDefense())*damage);

#add a move to the move queue
func addMoveToQueue(record:MoveRecord):
	if record.user:
		var preselected = record.move.getPreselectedTargets(); #get preselected targets and add them to our targets
		for i in preselected[0 if isCreatureFriendly(record.user) else 1]:
			if allies[i]:
				record.targets.push_back(allies[i]);
		for i in preselected[1 if isCreatureFriendly(record.user) else 0]:
			if enemies[i]:
				record.targets.push_back(enemies[i]);
				
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
	for i in allies:
		if i && !movesSelected.get(i):
			return false;
	return true;

func clearMovesSelected():
	movesSelected.clear();

func handlePlayerMove(user, move, targets):
	addMoveToQueue(MoveRecord.new(user,move,targets))
	#whether or not theres another ally that hasn't taken a turn yet

	for i in range(0,allies.size()):
		if allies[i] && !movesSelected.get(allies[i]):
			currentCreature = i;




