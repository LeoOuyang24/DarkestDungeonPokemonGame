class_name BattleManager extends Node2D

#facilitates communication between Battlefield and BattleUI

var BattleSim = Battlefield.new();
@onready var UI = $BattleUI

signal room_finished;

var sequencer = Sequencer.new();

enum BATTLE_STATES {
	SELECTING_MOVE,
	SELECTING_TARGET,
	BATTLE,
	WE_LOST,
	WE_WON,
	DONE
	}
	
	
	
var state:BATTLE_STATES = BATTLE_STATES.SELECTING_MOVE;

var currentMove=null;
var targetsNeeded = 1;
var targets = []

var playerCreature = null

@export var testing:bool = false;

var reward:Rewards = null

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.target_selected.connect(handleTargetSelect)
	UI.move_selected.connect(handleMoveSelect)
	UI.battle_finished.connect(battleFinished)
	
	
	BattleSim.add_move_queue.connect(func (record:MoveRecord, index:int):
		UI.addCreatureToQueue(record.user,index))
	BattleSim.remove_move_queue.connect(func (record:MoveRecord):
		UI.removeCreatureFromQueue(record.user));
	BattleSim.creature_died.connect(handleDeath)

	if testing:
		test();
		
	newTurn()

func test():
	var ally1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json")
	var ally2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json")
	var ally3 = Player.new().getPlayer()
	
	ally2.speed = 11;
	
	var enemy1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/dreemer.json")
	var enemy2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/siren.json")
	var enemy3 = CreatureLoader.loadJSON("res://Creatures/creautres_jsons/silent.json")
	
	enemy1.setMoves([Slash.new()]);
	enemy2.setMoves([Bite.new()]);
	enemy3.setMoves([Lure.new()])
	ally3.setMoves([SwapPos.new()])
	enemy2.speed = 10;
	
	createBattle(
		ally3,
		[
			ally1,
			ally2
		],
		[
			enemy1,
			enemy2,
			null,
			enemy3
		] );

func handleTargetSelect(index):
	if state == BATTLE_STATES.SELECTING_TARGET:
		var target = BattleSim.getCreature(index)
		if target && currentMove.isTargetValid(currentMove.targetingCriteria,true,BattleSim.isCreatureFriendly(target)):
			targets.push_back(index);
		if targets.size() >= targetsNeeded:
			BattleSim.handlePlayerMove(BattleSim.getCurrentCreature(),currentMove,targets)
			#BattleSim.addMoveToQueue(MoveRecord.new(BattleSim.getCurrentCreature(),currentMove,targets))
			changeState(BATTLE_STATES.SELECTING_MOVE)

func handleMoveSelect(move):
		if state == BATTLE_STATES.SELECTING_MOVE:
			#if invalid index, choose the pass turn move
			#this happens when we press the pass button as well
			#var move = BattleSim.getCurrentCreature().getMove(moveIndex)
			print(move)
			if move:
				currentMove = move;
			else:
				return #creature has less than max moves and we hit a blank button, do nothing
			targetsNeeded = currentMove.getNumOfTargets();
			changeState(BATTLE_STATES.SELECTING_TARGET)
			if targetsNeeded == 0:
				handleTargetSelect(-1)

func handleDeath(creature):
	if creature.isPlayerCreature():
		sequencer.insert(createPlayerDeathSequence(creature))
	else:
		sequencer.insert(SequenceUnit.createDeathSequence(creature))

static func createPlayerDeathSequence(creature:Creature):
	var sequence = []
	sequence.push_back(SequenceUnit.createTextUnit(creature.getName() + " has died!"))
	sequence.push_back(SequenceUnit.createSequenceUnit(func (d,m):
		m.changeState(BattleManager.BATTLE_STATES.WE_LOST)
		return SequenceUnit.RETURN_VALS.DONE
		,true))
	return sequence

func createBattle(player,allies,enemies):

	playerCreature = player
	allies = [player] + allies
	for i in range(allies.size()):
		if allies[i] && allies[i].isAlive():
			BattleSim.addCreature(allies[i],i);
	for i in range(enemies.size()):
		if enemies[i] && enemies[i].isAlive():
			BattleSim.addCreature(enemies[i],i + Battlefield.maxAllies);

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
	elif self.state == BATTLE_STATES.WE_LOST:
		UI.setEndScreen(false)
	elif self.state == BATTLE_STATES.WE_WON:
		reward = Rewards.new(5)
		UI.setEndScreen(true,reward)

func isPlayerTurn():
	return state != BATTLE_STATES.BATTLE && state != BATTLE_STATES.DONE;

func newTurn():
	if BattleSim.isDone() != Battlefield.BATTLE_OUTCOME.TBD:
		changeState(BATTLE_STATES.WE_WON)
	else:
		changeState(BATTLE_STATES.SELECTING_MOVE);
		BattleSim.newTurn();

func reset():
	playerCreature = null
	UI.reset();
	BattleSim.reset();
	pass

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
				sequencer.run(delta,self);
			else:
				#check if anyone died
				UI.resetAllSlotPos()
				if !BattleSim.checkForDeath():
					#get the next move
					var nextMove = BattleSim.popAndTop()
					if nextMove != null:
						sequencer.insert(nextMove);
					else:
						#no more moves to do
						newTurn();
		pass;
	pass

func battleFinished():
	if state == BATTLE_STATES.WE_WON:
		Game.GameState.setDNA(Game.GameState.getDNA() + reward.getDNA())
	room_finished.emit()
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSLASH:
			changeState(BATTLE_STATES.WE_WON)
