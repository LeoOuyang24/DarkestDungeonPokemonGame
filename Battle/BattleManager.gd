class_name BattleManager extends Node2D

#facilitates communication between Battlefield and BattleUI

@onready var BattleSim = Battlefield.new();
@onready var UI = $BattleUI

var sequencer = Sequencer.new();

enum BATTLE_STATES {
	SELECTING_MOVE,
	SELECTING_TARGET,
	BATTLE,
	DONE
	}
	
var state:BATTLE_STATES = BATTLE_STATES.SELECTING_MOVE;

var currentMove=null;
var targetsNeeded = 1;
var targets = []


@export var testing = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	UI.target_selected.connect(handleTargetSelect)
	UI.move_selected.connect(handleMoveSelect)
	
	BattleSim.add_move_queue.connect(func (record:MoveRecord, index:int):
		UI.addCreatureToQueue(record.user,index))
	BattleSim.remove_move_queue.connect(func (record:MoveRecord):
		UI.removeCreatureFromQueue(record.user));
	BattleSim.creature_died.connect(handleDeath)

	test();

	newTurn();
	pass # Replace with function body.

func test():
	if testing:
		var ally1 = Creature.create("spritesheets/creatures/chomper",100,"Chomper 1")
		var ally2 = Creature.create("spritesheets/creatures/chomper",100,"Chomper 2")
		var ally3 = Creature.create("spritesheets/creatures/player",300,"Player")
		
		
		ally2.speed = 11;
		ally3.speed = 12;
		
		ally1.setMoves([Bite.new(),HyperBeam.new(),NastyPlot.new()]);
		ally2.setMoves([NastyPlot.new(),Bite.new(),HyperBeam.new()]);
		ally3.setMoves([SwapPos.new()])
		
		var enemy1 = Creature.create("spritesheets/creatures/dreemer",100,"Dreemer 1")
		var enemy2 = Creature.create("spritesheets/creatures/dreemer",100,"Dreemer 2")
		
		enemy1.setMoves([HyperBeam.new()]);
		enemy2.setMoves([Bite.new()]);
		enemy2.speed = 10;
		
		createBattle(
			[
				ally1,
				ally2,
				ally3
			],
			[
				enemy1,
				enemy2
			] );

func handleTargetSelect(target):
		if state == BATTLE_STATES.SELECTING_TARGET:
			if target && currentMove.isTargetValid(currentMove.targetingCriteria,true,BattleSim.isCreatureFriendly(target)):
				targets.push_back(target);
			if targets.size() >= targetsNeeded:
				BattleSim.handlePlayerMove(BattleSim.getCurrentCreature(),currentMove,targets)
				changeState(BATTLE_STATES.SELECTING_MOVE)

func handleMoveSelect(moveIndex):
		if state == BATTLE_STATES.SELECTING_MOVE:
			#if invalid index, choose the pass turn move
			#this happens when we press the pass button as well
			if moveIndex >= Creature.maxMoves || moveIndex < 0: 
				currentMove = PassTurn.new();
			else:
				var move = BattleSim.getCurrentCreature().moves[moveIndex]
				if move:
					currentMove = move;
				else:
					return #creature has less than max moves and we hit a blank button, do nothing
			targetsNeeded = currentMove.targets;
			changeState(BATTLE_STATES.SELECTING_TARGET)
			if targetsNeeded == 0:
				handleTargetSelect(null)

func handleDeath(creature):
	sequencer.insert(SequenceUnit.createDeathSequence(creature))

func createBattle(allies, enemies):
	for i in range(allies.size()):
		BattleSim.addCreature(allies[i],i,true);
	for i in range(enemies.size()):
		BattleSim.addCreature(enemies[i],i,false);

func changeState(state):
	self.state = state;
	if self.state == BATTLE_STATES.SELECTING_MOVE:
		UI.choosingTargets(false);
		UI.setBattleText("Choose a move!");
		targets = [];
	elif self.state == BATTLE_STATES.SELECTING_TARGET:
		UI.choosingTargets(true,currentMove.targetingCriteria)
		UI.setBattleText("Choose targets!");
	elif self.state == BATTLE_STATES.BATTLE:
		var nextMove = BattleSim.moveQueue.topSequence()
		if nextMove:
			sequencer.insert(nextMove);	

func isPlayerTurn():
	return state != BATTLE_STATES.BATTLE && state != BATTLE_STATES.DONE;

func newTurn():
	if BattleSim.isDone() != Battlefield.BATTLE_OUTCOME.TBD:
		changeState(BATTLE_STATES.DONE)
	else:
		changeState(BATTLE_STATES.SELECTING_MOVE);
		BattleSim.newTurn();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	UI.setBattleState(BattleSim);
	if isPlayerTurn():
		if BattleSim.allMovesProcessed():
			changeState(BATTLE_STATES.BATTLE)
		pass;
	else:
		if state == BATTLE_STATES.DONE:
			UI.EndScreen.set_visible(true)
		else:
			if !sequencer.done():
				sequencer.run(delta,BattleSim,UI);
			else:
				#check if anyone died
				if !BattleSim.checkForDeath():
					#remove the old move
					
					#get the next move
					var nextMove = BattleSim.popAndTop()
					if nextMove != null:
						sequencer.insert(nextMove);
					else:
						#no more moves to do
						newTurn();
		pass;
	pass

