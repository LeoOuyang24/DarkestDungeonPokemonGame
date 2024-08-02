class_name BattleManager extends Node2D

#facilitates communication between Battlefield and BattleUI

var BattleSim = Battlefield.new();
@onready var UI = $BattleUI

signal room_finished(won:bool);

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

#current move being run
var curMove:Move.MoveRecord = null

var reward:Rewards = null

func getBattleSim() -> Battlefield:
	return BattleSim
	
func getBattleUI() -> BattleUI:
	return UI

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.target_selected.connect(handleTargetSelect)
	UI.move_selected.connect(handleMoveSelect)
	UI.battle_finished.connect(battleFinished)
	
	
	BattleSim.add_move_queue.connect(func (queue:Array):
		UI.updateQueue(queue)
		)
	BattleSim.remove_move_queue.connect(func (record:Move.MoveRecord):
		UI.removeCreatureFromQueue(record.user));
	BattleSim.creature_died.connect(handleDeath)
	BattleSim.creature_order_changed.connect(func(_added:bool):
		UI.setBattleState(BattleSim,isPlayerTurn())
		)
	BattleSim.new_current_creature.connect(func(creature:Creature):
		UI.setCurrentCreature(creature)
		)

	if testing:
		test();
		

func test():
	var ally1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json")
	var ally2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json")
	var ally3 = Player.new().getPlayer()
	
	
	var enemy1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/dreemer.json")
	var enemy2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/siren.json")
	var enemy3 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/silent.json")
	
	
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
	allies += [player]
	for i in range(allies.size()):
		if allies[i] && allies[i].isAlive():
			BattleSim.addCreature(allies[i],i);
	for i in range(enemies.size()):
		if enemies[i] && enemies[i].isAlive():
			BattleSim.addCreature(enemies[i],i + Battlefield.maxAllies);

func changeState(state):
	self.state = state;
	UI.setBattleState(BattleSim,isPlayerTurn());
	if self.state == BATTLE_STATES.SELECTING_MOVE:
		UI.choosingTargets(false);
		UI.setBattleText("Choose a move!");
		targets = [];
	elif self.state == BATTLE_STATES.SELECTING_TARGET:
		UI.choosingTargets(true,currentMove.targetingCriteria)
		UI.setBattleText("Choose targets!");
	elif self.state == BATTLE_STATES.BATTLE:
		await runBattle()
	elif self.state == BATTLE_STATES.WE_LOST:
		UI.setEndScreen(false)
	elif self.state == BATTLE_STATES.WE_WON:
		reward = Rewards.new(5)
		UI.setEndScreen(true,reward)


func isPlayerTurn():
	return state == BATTLE_STATES.SELECTING_MOVE || state == BATTLE_STATES.SELECTING_TARGET;

func newTurn():
	changeState(BATTLE_STATES.SELECTING_MOVE);
	BattleSim.newTurn();
	UI.newTurn();

func reset():
	playerCreature = null
	UI.reset();
	BattleSim.reset();
	pass

func runMove(user:Creature,move:Move,targets:Array) -> void:
	targets.append_array(move.getPreselectedTargets(user,BattleSim))
	UI.setBattleText(user.getName() + " used " + move.getMoveName() + "!")
	await get_tree().create_timer(1).timeout
	
	await move.runAnimation(user,targets,UI,BattleSim)
	
	move.doMove(user,targets,BattleSim)
	
	if move.getPostMessage(user,targets) != "":
		UI.setBattleText(move.getPostMessage(user,targets))
		await get_tree().create_timer(1).timeout

func runDeath(dead:Creature) -> void:
	UI.setBattleText(dead.getName() + " died.")
	await get_tree().create_timer(1).timeout
	
	BattleSim.removeCreature(dead)


func runBattle():
	curMove = BattleSim.popAndTop()
	while curMove:
		await runMove(curMove.user,curMove.move,curMove.targets)
		#UI.resetAllSlotPos()
		var dead = BattleSim.checkForDeath()
		while dead != -1:
			await runDeath(BattleSim.getCreature(dead))
			dead = BattleSim.checkForDeath()
		curMove = BattleSim.popAndTop()	

	if !GameState.PlayerState.getPlayer().isAlive():
		changeState(BATTLE_STATES.WE_LOST)
	elif BattleSim.isDone():
		changeState(BATTLE_STATES.WE_WON)
	else:
		newTurn()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#UI.setBattleState(BattleSim);
	if isPlayerTurn():
		if BattleSim.allMovesProcessed():
			changeState(BATTLE_STATES.BATTLE)

func battleFinished():
	if state == BATTLE_STATES.WE_WON:
		GameState.setDNA(GameState.getDNA() + reward.getDNA())
	room_finished.emit(state == BATTLE_STATES.WE_WON)
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSLASH:
			changeState(BATTLE_STATES.WE_WON)
		elif event.keycode == KEY_BACKSPACE:
			changeState(BATTLE_STATES.WE_LOST)
