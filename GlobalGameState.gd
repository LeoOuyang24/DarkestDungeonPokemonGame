class_name GlobalGameState extends Object

#represents the global game state, etc amount of DNA and gold

signal DNA_changed(amount)

#amount of DNA we have
var DNA:int = 0

func _init() -> void:
	setDNA(5)

func getDNA() -> int:
	return DNA

func setDNA(amount:int) -> void:
	DNA = amount
	DNA_changed.emit(amount)

