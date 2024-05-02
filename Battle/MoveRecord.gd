class_name MoveRecord extends Object

#represents the info associated with the use of a move

var move:Move = null #the move
var user:Creature = null #user of the move
var targets:Array = [] #array of creatures that are the target

func _init( user:Creature, targets:Array, move:Move):
	self.move = move;
	self.user = user;
	self.targets = targets;
	
func getSequence():
	if move:
		return move.createMoveSequence(user,targets,move);
