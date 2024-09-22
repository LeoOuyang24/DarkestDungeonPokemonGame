extends Object

#represents the global game state, etc amount of DNA and gold

signal DNA_changed(amount)

static var PlayerState:Player = Player.new()

#amount of DNA we have
var DNA:int = 0

#true if we are in battle
var inBattle:bool = false

func initiate() -> void:
	setDNA(1000)

func _ready() -> void:
	initiate()

func getDNA() -> int:
	return DNA

func setDNA(amount:int) -> void:
	DNA = amount
	DNA_changed.emit(amount)

func getInBattle() -> bool:
	return inBattle

func setInBattle(inBattle:bool) -> void:
	self.inBattle = inBattle



