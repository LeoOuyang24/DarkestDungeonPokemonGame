class_name BattleManager extends RoomBase

#facilitates communication between Battlefield and BattleUI

var BattleSim:Battlefield = Battlefield.new();
@onready var UI:BattleUI = $BattleUI

enum BATTLE_STATES {
	SELECTING_MOVE,
	SELECTING_TARGET,
	BATTLE,
	WE_LOST,
	WE_WON,
	DONE
	}
	
	
	
var state:BATTLE_STATES = BATTLE_STATES.SELECTING_MOVE;

@export var testing:bool = false;

#current move being run
var curMove:Move.MoveRecord = Move.MoveRecord.new()

var reward:Rewards = null

func getBattleSim() -> Battlefield:
	return BattleSim
	
func getBattleUI() -> BattleUI:
	return UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI.target_selected.connect(handleTargetSelect)
	UI.move_selected.connect(handleMoveSelect)
	UI.battle_finished.connect(battleFinished)
	
	
	BattleSim.add_move_queue.connect(UI.updateQueue)
	BattleSim.creature_added.connect(UI.addCreature)
	BattleSim.creature_removed.connect(UI.removeCreature)
	BattleSim.creature_order_changed.connect(UI.updateSlots.bind(BattleSim))
	BattleSim.queue_order_changed.connect(func(_c,_i,_n):
		UI.updateQueue(BattleSim.getFullQueue())
		)
	BattleSim.pop_move_queue.connect(func(record:Move.MoveRecord):
		UI.popCreatureFromQueue(record.user)
		)

	if testing:
		test();
	UI.updateSlots(BattleSim)
	await UI.is_ready;
	
	newTurn(true)
		

func test() -> void:
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

func handleTargetSelect(index:int) -> void:
	if state == BATTLE_STATES.SELECTING_TARGET && curMove.move:
		var target = BattleSim.getCreature(index)
		if target && curMove.move.isTargetValid(curMove.move.targetingCriteria,BattleSim.getCurrentCreature(),target):
			curMove.targets.push_back(index);
			if curMove.targets.size() >= curMove.move.getNumOfTargets():
				handleMoveDone()

func handleMoveSelect(move:Move):
		if state == BATTLE_STATES.SELECTING_MOVE && move:
			curMove.move = move;
			if move.getNumOfTargets() == 0:
				handleMoveDone()
			else:
				changeState(BATTLE_STATES.SELECTING_TARGET)

#handle a move that has had targets selected
func handleMoveDone() -> void:
	curMove.user = BattleSim.getCurrentCreature()
	BattleSim.handlePlayerMove(curMove.copy())
	if BattleSim.allMovesProcessed():
		changeState(BATTLE_STATES.BATTLE)
	else:
		changeState(BATTLE_STATES.SELECTING_MOVE)
	
	curMove = Move.MoveRecord.new() #make a new record

func createBattle(player,allies,enemies):
	#allies += [player]
	for i in range(allies.size()):
		if allies[i] && allies[i].isAlive():
			BattleSim.addCreature(allies[i],i);
	for i in range(enemies.size()):
		if enemies[i] && enemies[i].isAlive():
			BattleSim.addCreature(enemies[i],i + Battlefield.maxAllies);

func changeState(state):
	self.state = state;
	#UI.setBattleState(BattleSim);
	UI.resetSlotUIs()
	UI.setCurrentCreature(BattleSim.getCurrentCreature())
	if self.state == BATTLE_STATES.SELECTING_MOVE:
		#UI.resetSlotUIs();
		#UI.setCurrentCreature(BattleSim.getCurrentCreature())
		UI.setBattleText("Choose a move!");
	elif self.state == BATTLE_STATES.SELECTING_TARGET:
		UI.choosingTargets(curMove.move.targetingCriteria)
		UI.setBattleText("Choose targets!");
	elif self.state == BATTLE_STATES.BATTLE:
		await runBattle()
	elif self.state == BATTLE_STATES.WE_WON:
		reward = Rewards.new(5)
		UI.setEndScreen(reward)


func isPlayerTurn():
	return state == BATTLE_STATES.SELECTING_MOVE || state == BATTLE_STATES.SELECTING_TARGET;

func newTurn(first:bool=false):
	if first:
		BattleSim.firstTurn();
	else:
		BattleSim.newTurn();
	UI.newTurn(BattleSim);
	#await UI.AllyRow.sort_children

	changeState(BATTLE_STATES.SELECTING_MOVE);

func reset():
	UI.reset();
	BattleSim.reset();
	curMove = Move.MoveRecord.new()

func runMove(user:Creature,move:Move,targets:Array) -> void:
	if user.statuses.getStatus("Sleep"):
		UI.setBattleText(user.getName() + " is asleep");
		await get_tree().create_timer(1).timeout
	else:
		if !move:
			#null moves are handeled like PassTurns
			await runMove(user,PassTurn.new(),targets)
		else:
			targets.append_array(move.getPreselectedTargets(user,BattleSim))
			UI.setBattleText(user.getName() + " used " + move.getMoveName() + "!")
			await get_tree().create_timer(1).timeout
			var call:Callable = func():
				pass

			await move.runAnimation(user,targets,UI,BattleSim)
			
			move.doMove(user,targets,BattleSim)
			
			if move.getPostMessage(user,targets,BattleSim) != "":
				UI.setBattleText(move.getPostMessage(user,targets,BattleSim))
				await get_tree().create_timer(1).timeout

func runDeath(dead:Creature) -> void:
	UI.setBattleText(dead.getName() + " died.")
	await get_tree().create_timer(1).timeout
	BattleSim.removeCreature(dead)


func runBattle():
	await UI.startBattle()
	
	var runThis := BattleSim.getNextMove()

	while runThis:
		#print(BattleSim.moveQueue.data)
		UI.setCurrentCreature(runThis.user)
		await runMove(runThis.user,runThis.move,runThis.targets)
		var dead = BattleSim.checkForDeath()
		while dead != -1:
			await runDeath(BattleSim.getCreature(dead))
			dead = BattleSim.checkForDeath()
			await UI.is_ready
		if !GameState.PlayerState.getPlayer().isAlive():
			changeState(BATTLE_STATES.WE_LOST)
			return 
		else:
			#BattleSim.nextMove();
			runThis = BattleSim.getNextMove()
		UI.resetAllSlotPos()
			
	if BattleSim.isDone():
		changeState(BATTLE_STATES.WE_WON)
	else:
		newTurn()

func battleFinished():
	BattleSim.battle_ended.emit()
	BattleSim.onBattleEnd()
	if state == BATTLE_STATES.WE_WON:
		GameState.setDNA(GameState.getDNA() + reward.getDNA())
	elif state == BATTLE_STATES.WE_LOST:
		GameState.loseGame();
	room_finished.emit()
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSLASH:
			changeState(BATTLE_STATES.WE_WON)
		if event.keycode == KEY_BACKSPACE:
			GameState.PlayerState.getPlayer().stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(0,false,self)	
