extends Node2D

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
		
	BattleSim.creature_died.connect(handleDeath)
		
	if testing:
		var ally1 = Creature.create("spritesheets/creatures/dialga",100,"Dialga")
		var ally2 = Creature.create("spritesheets/creatures/dialga",100,"Dialga")
		
		ally1.setMoves([Tackle.new(),HyperBeam.new()]);
		ally2.setMoves([NastyPlot.new(),Splash.new(),HyperBeam.new()]);
		
		var enemy1 = Creature.create("spritesheets/creatures/magikarp",100,"Magikarp")
		var enemy2 = Creature.create("spritesheets/creatures/magikarp",100,"Magikarp")
		
		enemy1.setMoves([Splash.new()]);
		enemy2.setMoves([Tackle.new()]);
		enemy2.speed = 10;
		
		createBattle(
			[
				ally1,
				ally2
			],
			[
				enemy1,
				enemy2
			] );
	
	pass # Replace with function body.

func handleTargetSelect(target):
		if state == BATTLE_STATES.SELECTING_TARGET:
			targets.push_back(target);
			if targets.size() >= targetsNeeded:
				BattleSim.handlePlayerMove(BattleSim.getCurrentCreature(),targets,currentMove)
				changeState(BATTLE_STATES.SELECTING_MOVE)

func handleMoveSelect(moveIndex):
		if state == BATTLE_STATES.SELECTING_MOVE:
			var move = BattleSim.getCurrentCreature().moves[moveIndex]
			if move:
				currentMove = move;
				changeState(BATTLE_STATES.SELECTING_TARGET)

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
		UI.choosingTargets(true)
		UI.setBattleText("Choose targets!");

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
					var nextMove = BattleSim.moveQueue.pop()
					if nextMove:
						sequencer.insert(nextMove);
					else:
						#no more moves to do
						newTurn();
		pass;
	pass

