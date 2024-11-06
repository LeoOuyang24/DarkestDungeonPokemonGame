extends Object

#represents the global game state, etc amount of DNA and gold

signal DNA_changed(amount)
signal game_lost()

static var PlayerState:Player = Player.new()
#amount of DNA we have
var DNA:int = 0

#true if we are in battle
var inBattle:bool = false

func initiate() -> void:
	setDNA(1000)
	PlayerState.getPlayer().stats.getStatObj(CreatureStats.STATS.HEALTH).stat_changed.connect(func(amount,val):
		if !PlayerState.getPlayer().isAlive():
			game_lost.emit();
		)

func reset() -> void:
	PlayerState.reset();
	initiate();
	

func _ready() -> void:

	initiate()

func loseGame() -> void:
	game_lost.emit();

func getDNA() -> int:
	return DNA

func setDNA(amount:int) -> void:
	DNA = amount
	DNA_changed.emit(amount)

func getInBattle() -> bool:
	return inBattle

func setInBattle(inBattle:bool) -> void:
	self.inBattle = inBattle



