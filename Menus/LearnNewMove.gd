extends Control


@onready var LevelUpMove:MoveButton = $NewMove/Pending
@onready var ConfirmButton:Button = $NewMove/Confirm 
@onready var Moves:Array[MoveButton] = [$Moves/Button,$Moves/Button2,$Moves/Button3,$Moves/Button4] 
@onready var NewMove=$NewMove

signal new_move_confirmed(moves:Array) #emitted after we've learned a new move (or rejected learning one). Parameter is the creature's new set of moves

# Called when the node enters the scene tree for the first time.
func _ready():
	setNewMove(null)
	pass # Replace with function body.

func setMoves(creature:Creature):
	if creature:
		for i in range(Creature.maxMoves):
			Moves[i].disabled = true
			Moves[i].setMove(creature.getMove(i))
			Moves[i].move_selected.connect(func(move):
				if LevelUpMove.getMove():
					swapMove(Moves[i]))

func setNewMove(move:Move) -> void:
	LevelUpMove.setMove(move)
	var moveExists:bool = (move != null)
	for i in Moves:
		i.disabled = !moveExists
	for i in NewMove.get_children():
		i.visible = moveExists
	ConfirmButton.disabled = !moveExists
		

#swap the chosen move with the move on the LevelUpMove button
func swapMove(moveButton:MoveButton):
	var move = moveButton.getMove()
	moveButton.setMove(LevelUpMove.getMove())
	LevelUpMove.setMove(move)


func _on_confirm_pressed():
	setNewMove(null)
		
	new_move_confirmed.emit(Moves.map(func (button):
		return button.getMove()
		))
	
	pass # Replace with function body.