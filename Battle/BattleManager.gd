class_name BattleManager extends RoomBase

#facilitates communication between Battlefield and BattleUI

var BattleSim:Battlefield = Battlefield.new();
@onready var UI:BattleUI = $BattleUI

enum BATTLE_STATES {
	PLAYER_TURN, #used for when we are still taking our turn
	BATTLE,
	WE_LOST,
	WE_WON,
	DONE
	}
	
	
	
var state:BATTLE_STATES = BATTLE_STATES.PLAYER_TURN;

@export var testing:bool = false;

var reward:Rewards = null

func getBattleSim() -> Battlefield:
	return BattleSim
	
func getBattleUI() -> BattleUI:
	return UI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#UI.target_selected.connect(handleTargetSelect)
	#UI.move_selected.connect(handleMoveSelect)
	UI.turn_made.connect(handleRecord)
	UI.battle_finished.connect(battleFinished)
	UI.end_turn.connect(changeState.bind(BATTLE_STATES.BATTLE))
	
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

func handleRecord(record:Move.MoveRecord) -> void:
	BattleSim.handlePlayerMove(record)
	changeState(BATTLE_STATES.PLAYER_TURN)

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
	#UI.resetSlotUIs()
	if self.state == BATTLE_STATES.PLAYER_TURN:
		var next := BattleSim.getCreatureWithNoRecord() #get next creature that has not taken a turn
		if next: 
			UI.setCurrentCreature(next)
		else: #if there is none, enable the End Turn button
			UI.EndTurn.disabled = false
	elif self.state == BATTLE_STATES.BATTLE:
		UI.EndTurn.disabled = true
		await runBattle()
	elif self.state == BATTLE_STATES.WE_WON:
		reward = Rewards.new(5)
		UI.setEndScreen(reward)


func isPlayerTurn():
	return state == BATTLE_STATES.PLAYER_TURN

func newTurn(first:bool=false):
	if first:
		BattleSim.firstTurn();
	else:
		BattleSim.newTurn();
	UI.newTurn(BattleSim);
	#await UI.AllyRow.sort_children

	changeState(BATTLE_STATES.PLAYER_TURN);

func reset():
	UI.reset();
	BattleSim.reset();

func runMove(record:Move.MoveRecord) -> void:
	if record.user.statuses.getStatus("Sleep"):
		UI.setBattleText(record.user.getName() + " is asleep");
		await get_tree().create_timer(1).timeout
	else:
		if !record.move:
			#null moves are handeled like PassTurns
			Move.MoveRecord.new()
			await runMove(Move.MoveRecord.new(record.user,PassTurn.new(),record.targets))
		else:
			record.targets.append_array(record.move.getPreselectedTargets(record.user,BattleSim))
			UI.setBattleText(record.user.getName() + " used " + record.move.getMoveName() + "!")
			await get_tree().create_timer(1).timeout
			var call:Callable = func():
				pass
			await UI.showMove(record)
			await record.move.runAnimation(record.user,record.targets,UI,BattleSim)
			
			record.move.doMove(record.user,record.targets,BattleSim)
			
			UI.clearMove()
				
			UI.History.addMove(record)

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
		await runMove(runThis)
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
