class_name Rewards extends Object

#represents the reward from winning a battle

var dna:int = 0

func _init(dna_:int) -> void:
	dna = dna_
	
func getDNA() -> int:
	return dna
