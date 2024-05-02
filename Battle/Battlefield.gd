class_name Battlefield extends Node

#general battle logic

#index of the current player creature we are choosing moves for
#null if we aren't showing player creature moves
var currentCreature = 0;

const maxAllies = 4;
const maxEnemies = 4;

var allies = []
var enemies = []
var movesSelected = {};

var moveQueue = MoveQueue.new();

signal creature_died(creature:Creature);

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


func addCreature(creature:Creature, index:int, isAlly:bool):
	var row = null; #array of creatures, either the enemies or allies
	var max = 0;
	if isAlly:
		row = allies;
		max = maxAllies;
	else:
		row = enemies;
		max = maxEnemies;
	
	if index >= 0 && index < max && row[index] == null:
		row[index] = creature;
				

func removeCreature(creature:Creature):
	processAllCreatures(func(creatures, isAlly):
		for i in range(creatures.size()):
			if creatures[i] == creature:
				creatures[i] = null
				movesSelected.erase(creature);
				return true;
		)

func _ready():
	pass

func newTurn():
	currentCreature = 0;
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



#add a move to the move queue
func addMoveToQueue(record:MoveRecord):
	if record.user:
		moveQueue.insert(record);
		movesSelected[record.user] = record;

#returns whether all players have selected a move
func allMovesProcessed():
	for i in allies:
		if i && !movesSelected.get(i):
			return false;
	return true;

func clearMovesSelected():
	movesSelected.clear();

func handlePlayerMove(user, targets,move):
	addMoveToQueue(MoveRecord.new(user,targets,move))
	#whether or not theres another ally that hasn't taken a turn yet

	for i in range(0,allies.size()):
		if allies[i]:
			currentCreature = i;




