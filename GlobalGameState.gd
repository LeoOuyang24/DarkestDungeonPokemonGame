extends Node

#represents the global game state, etc amount of DNA and gold

#emits the new amount of dna we have
signal DNA_changed(amount)
signal battle_started() 
signal game_lost()

var PlayerState:Player = null;#Player.new()
var isTutorial:bool = false
#amount of DNA we have
var DNA:int = 0

#the current battlefield, null if not in battle
var currentBattle:Battlefield = null

func initiate() -> void:
	setDNA(20)
	PlayerState = Player.new()
	PlayerState.getPlayer().stats.getStatObj(CreatureStats.STATS.HEALTH).stat_changed.connect(func(amount,val):
		if !PlayerState.getPlayer().isAlive():
			game_lost.emit();
		)

func reset() -> void:
	PlayerState.reset();
	initiate();
	

func _ready() -> void:
	initiate()
	pass

func loseGame() -> void:
	game_lost.emit();

func getDNA() -> int:
	return DNA

func setDNA(amount:int) -> void:
	DNA = amount
	DNA_changed.emit(amount)

func getBattle() -> Battlefield:
	return currentBattle

func setBattle(inBattle:Battlefield) -> void:
	self.currentBattle = inBattle
	if inBattle:
		battle_started.emit()
