extends Control


@onready var LevelUpMove:MoveButton = %Pending
@onready var ConfirmButton:Button = %Confirm 
@onready var Moves = $Moves 
@onready var NewMove=$NewMove

signal new_move_confirmed(moves:Array) #emitted after we've learned a new move (or rejected learning one). Parameter is the creature's new set of moves

var creature:Creature = null

# Called when the node enters the scene tree for the first time.
func _ready():
	setNewMove(null)
	Moves.move_selected.connect(func(_move,button) -> void:
		if LevelUpMove.getMove():
			swapMove(button)
		)
	pass # Replace with function body.

func setMoves(creature:Creature):
	Moves.setMoves(creature)

#update the next move to be learned via level up
func setNewMove(move:Move) -> void:
	LevelUpMove.setMove(move)
	var moveExists:bool = (move != null)
	#Moves.disableMoves(!moveExists)
	for i in NewMove.get_children():
		i.visible = moveExists
	ConfirmButton.disabled = !moveExists
		

#swap the chosen move with the move on the LevelUpMove button
func swapMove(moveButton:MoveButton):
	var move = moveButton.getMove()
	moveButton.setMove(LevelUpMove.getMove())
	#moveButton.setMove(LevelUpMove.getMove(),creature)
	LevelUpMove.setMove(move)


func _on_confirm_pressed():
	setNewMove(null)
		
	new_move_confirmed.emit(Moves.Moves.map(func(butt:MoveButton): 
		return butt.getMove()
		))
	
	pass # Replace with function body.
