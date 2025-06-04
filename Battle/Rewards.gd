class_name Rewards extends Object

#represents the reward from winning a battle

var dna:int = 0
#array of moves to learn
var moves:Array = []

static func createReward():
	var moves := []
	if randi()%100 >= 0:
		moves.push_back(CreatureLevel.getRandomMove())
	return Rewards.new(randi()%10 + 5,moves)

func _init(dna_:int,moves_:Array = []) -> void:
	dna = dna_
	moves = moves_
	
func getDNA() -> int:
	return dna
