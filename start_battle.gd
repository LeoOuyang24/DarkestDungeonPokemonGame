class_name Battlefield extends Node2D

#general battle logic

#index of the current player creature we are choosing moves for
#null if we aren't showing player creature moves
var currentCreature = 0;

const maxAllies = 4;
const maxEnemies = 4;

var allies = []
var enemies = []

var moveQueue = MoveQueue.new();

var sequencer = []; #list of sequence units

enum BATTLE_STATES {
	PLAYER_TURN,
  ENEMY_TURN,
	BATTLE
	}
	
@export var state = BATTLE_STATES.PLAYER_TURN;
var animeStart = -1; #the time we started with animations
# Called when the node enters the scene tree for the first time.

@onready var BattleUI = $BattleUI

func _init():
	allies.resize(maxAllies)
	allies.fill(null)
	
	enemies.resize(maxEnemies);
	enemies.fill(null)
	

func getCurrentCreature():
	if currentCreature < allies.size() && currentCreature>=0:
		return allies[currentCreature]
	return null;
func setBattleText(text:String):
	BattleUI.BattleLog.set_text(text)
	
func setState(state_):
	state = state_
	#print_debug(sequencer)
	if (state == BATTLE_STATES.PLAYER_TURN):
		if BattleUI.BattleLog:
			setBattleText("What will you do??")
		else:
			push_error("BATTLE LOG NOT ADDED AS CHILD TO BATTLE")

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

func removeCreature(index:int, isAlly:bool):
	var array = allies if isAlly else enemies;
	if index < array.size() && index >= 0 && array[index]:
		addSequence(SequenceUnit.createDeathSequence(array[index]));
		array[index] = null

		

func _ready():
	
		# Register signal handler for the end of targeting process,
	# which handles creature damage and
	BattleUI.targets_selected.connect(handlePlayerMove);

	var player = Creature.create("dialga",100,"Player")

	player.setAttacks([Tackle.new(),HyperBeam.new(),NastyPlot.new()]);
	addCreature(player,0,true);
	

	var player2 = Creature.create("dialga",100,"Player")
	player2.setAttacks([Tackle.new()])
	addCreature(player2,1,true);
	
	var enemy = Creature.create("magikarp",100,"Enemy");
	enemy.setAttacks([Splash.new()])
	addCreature(enemy,0,false);
	
	var enemy2 = Creature.create("magikarp",100,"Enemy");
	enemy2.setAttacks([Tackle.new()])
	enemy2.speed = 100;
	addCreature(enemy2,1,false);

	setState(BATTLE_STATES.BATTLE)
	pass


#set a move's animation. If null, stop rendering the current animation
func setBattleSprite(sprite:SpriteFrames) -> void:
	if sprite == null:
		BattleUI.stopBattleSprite();
	else:
		BattleUI.setBattleSprite(sprite);

# Called every frame. 'delta' is the elapsed time since the previous frame.
var _statedebugstr = 'startbattle state: %s\nbattleui state: %s'
func _process(delta):
	if $BattleUI/DebugStartBattleState:
		$BattleUI/DebugStartBattleState.set_text(
			 _statedebugstr % [BATTLE_STATES.keys()[state], BattleUI.States.keys()[BattleUI.state]]
		);
				

	if (state == BATTLE_STATES.BATTLE):
		if sequencer.size() > 0:
			if sequencer[len(sequencer)  - 1].run(delta,self): #if we are done with this unit ...
				sequencer.pop_back(); #...remove it
		#finished processing a move
		else:


			#check if there's more moves to process
			if moveQueue.data.size() > 0:
				#add it to sequence
				moveQueue.pop();
			#all moves have been processed, back to player turn
			else:
				setState(BATTLE_STATES.PLAYER_TURN)
						#check if any creatures have died between moves
			var found = false
			var lambda = func(array,isAlly):
				for i in range(array.size()):
					if (array[i] && !array[i].isAlive()):
						found = true
						removeCreature(i,isAlly)
						print(sequencer.size())
						
			lambda.call(allies,true);
			lambda.call(enemies,false);
		

		# On player move:
		# add attacks to UI and set BattleUI to move selection state.
		# Register signal handler for the end of the targeting process, which will handle creature damage and requeueing the current creature.
		# Meanwhile, set state to PLAYER_WAIT so that the battle doesn't advance without player input.

		#elif (state == BATTLE_STATES.PLAYER_WAIT)
		
		# On enemy move:
		# use CreatureAI to determine which move to make, execute move, then requeue at back.
	elif (state == BATTLE_STATES.ENEMY_TURN):
		#TODO should probably add signal to enemy, to mimic callback after player input
		for i in enemies:
			if i:
				addMoveToQueue(i,allies,Creature.AI(i,enemies,allies))
		setState(BATTLE_STATES.BATTLE)
	BattleUI.setBattleState(self);

#add a move to the move queue
func addMoveToQueue(user, targets, move):
	moveQueue.insert(user,processMove.bind(user,targets,move));

func handlePlayerMove(user, targets,move):
	addMoveToQueue(user,targets,move)
	#whether or not theres another ally that hasn't taken a turn yet
	var found = false;
	for i in range(currentCreature+1,allies.size()):
		if allies[i]:
			currentCreature = i;
			found = true;
	#we've looped, every player character has gone!
	if !found:
		setState(BATTLE_STATES.ENEMY_TURN);
		currentCreature = 0;

func addSequence(sequence):
	#copy the array in reverse order, because popping from the back is easier than popping from the front
	for i in range(len(sequence) - 1, -1,-1):
		sequencer.append(sequence[i])

#add a move to the sequence
func processMove(user,targets,move):
	#var sequence = SequenceUnit.createMoveSequence(user,move,targets)
	var sequence = move.createMoveSequence(user,move,targets)
	addSequence(sequence);


