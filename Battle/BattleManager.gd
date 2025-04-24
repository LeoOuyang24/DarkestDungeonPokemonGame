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
	UI.turn_made.connect(handleRecord)
	UI.battle_finished.connect(battleFinished)
	UI.end_turn.connect(changeState.bind(BATTLE_STATES.BATTLE))
	
	BattleSim.add_move_queue.connect(UI.updateQueue)
	BattleSim.creature_added.connect(UI.addCreature)
	BattleSim.creature_removed.connect(UI.removeCreature)
	BattleSim.creature_order_changed.connect(UI.updateSlots.bind(BattleSim))
	BattleSim.queue_order_changed.connect(func(data):
		UI.updateQueue(data)
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
	
	
	createBattleFull(
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

func createBattle(enemies):
	createBattleFull(GameState.PlayerState.getPlayer(),GameState.PlayerState.getTeam(),enemies)

func createBattleFull(player,allies,enemies):
	#allies += [player]
	BattleSim.reset()
	for i in range(allies.size()):
		if allies[i] && (allies[i].isAlive()):
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
	if BattleSim.isDone():
		changeState(BATTLE_STATES.WE_WON)
	else:
		changeState(BATTLE_STATES.PLAYER_TURN);

func reset():
	UI.reset();
	BattleSim.reset();

func runMove(record:Move.MoveRecord) -> void:
	if !record.user.isActive():
		await get_tree().create_timer(1*BattleUI.battleSpeed).timeout
	else:
		if !record.move:
			#null moves are handeled like PassTurns
			Move.MoveRecord.new()
			await runMove(Move.MoveRecord.new(record.user,PassTurn.new(),record.targets))
		else:
			record.targets.append_array(record.move.getPreselectedTargets(record.user,BattleSim))
			await get_tree().create_timer(1).timeout

			await UI.showMove(record)
			await record.move.runAnimation(record.user,record.targets,UI,BattleSim)

			if record.move.slot:
				record.move.slot.doMove(record.user,record.targets,BattleSim)
			else:
				record.move.move(record.user,record.targets,BattleSim)

			UI.clearMove()
				
			UI.History.addMove(record)

func runDeath(dead:Creature) -> void:
	await get_tree().create_timer(1).timeout
	BattleSim.removeCreature(dead)


func runBattle():
	await UI.startBattle()
	
	var runThis := BattleSim.getNextMove()

	while runThis:
		UI.setCurrentCreature(runThis.user)
		await runMove(runThis)
		var dead = BattleSim.checkForDeath()
		while dead != -1:
			await runDeath(BattleSim.getCreature(dead))
			dead = BattleSim.checkForDeath()
		if !GameState.PlayerState.getPlayer().isAlive():
			changeState(BATTLE_STATES.WE_LOST)
			return 
		elif BattleSim.isDone():
			changeState(BATTLE_STATES.WE_WON)
			break;
		else:
			#BattleSim.nextMove();
			runThis = BattleSim.getNextMove()
		UI.resetAllSlotPos()
	newTurn()

func battleFinished():
	BattleSim.battle_ended.emit()
	BattleSim.onBattleEnd()
	if state == BATTLE_STATES.WE_WON:
		GameState.setDNA(GameState.getDNA() + reward.getDNA())
	elif state == BATTLE_STATES.WE_LOST:
		GameState.loseGame();
	room_finished.emit()
	
#func _input(event):
	#if event is InputEventKey and event.pressed:
		#if event.keycode == KEY_BACKSLASH:
			#changeState(BATTLE_STATES.WE_WON)
		#if event.keycode == KEY_BACKSPACE:
			#GameState.PlayerState.getPlayer().stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(0,false,self)	
