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
	#can't change state after battle is over
	if self.state != BATTLE_STATES.WE_WON and self.state != BATTLE_STATES.WE_LOST:
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
			reward = Rewards.createReward()
			UI.setEndScreen(reward)


func isPlayerTurn():
	return state == BATTLE_STATES.PLAYER_TURN

func newTurn(first:bool=false):
	if first:
		BattleSim.firstTurn();
	else:
		BattleSim.newTurn();
	await UI.newTurn(BattleSim);
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
			await runMove(Move.MoveRecord.new(record.user,PassTurn.new(),record.targets))
		else:
			await get_tree().create_timer(1).timeout

			await UI.showMove(record)

			if record.move.slot:
				await record.move.slot.doMove(record,self)
			else:
				await record.move.fullMove(record,self)

			UI.clearMove()
				
			UI.History.addMove(record)

#checks and runs deaths
#if the deaths result in a win/loss, return true
func checkDeath() -> bool:
	var dead := BattleSim.checkForDeath()
	while dead:
		await get_tree().create_timer(1).timeout
		BattleSim.removeCreature(dead)
		dead = BattleSim.checkForDeath()
	if !GameState.PlayerState.getPlayer().isAlive():
		changeState(BATTLE_STATES.WE_LOST)
		return true
	elif BattleSim.isDone():
		changeState(BATTLE_STATES.WE_WON)
		return true
	return false

func runBattle():
	await UI.startBattle()
	
	var runThis := BattleSim.getNextMove()

	while runThis:
		UI.setCurrentCreature(runThis.user)
		await runMove(runThis)

		if (await checkDeath()):
			break

		runThis = BattleSim.getNextMove()
		UI.resetAllSlotPos()
	await get_tree().create_timer(.5).timeout
	await endTurn()
	await newTurn()
#stuff that happens at end of turn
func endTurn():
	BattleSim.endTurn()
	await UI.endTurn()
	await checkDeath();

func battleFinished():
	BattleSim.battle_ended.emit()
	BattleSim.onBattleEnd()
	if state == BATTLE_STATES.WE_WON:
		GameState.setDNA(GameState.getDNA() + reward.getDNA())
		if reward.moves.size() > 0:
			GameState.PlayerState.addMove(reward.moves[0])
	elif state == BATTLE_STATES.WE_LOST:
		GameState.loseGame();
	room_finished.emit()
	
#func _input(event):
	#if event is InputEventKey and event.pressed:
		#if event.keycode == KEY_BACKSLASH:
			#changeState(BATTLE_STATES.WE_WON)
		#if event.keycode == KEY_BACKSPACE:
			#GameState.PlayerState.getPlayer().stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(0,false,self)	
