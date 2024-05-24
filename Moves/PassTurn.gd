class_name PassTurn extends Move

#an empty move that just passes the turn

func _init():
	moveName = "Pass Turn"

func createMoveSequence(user, move,targets):
	return []

