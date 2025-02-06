extends Control

# a ui element that shows the move a creature is gonna use
	
@onready var PendingMove = %PendingMove	
	

func setMove(move:Move,creature:Creature):
	PendingMove.move = move
	PendingMove.creature = creature
	
