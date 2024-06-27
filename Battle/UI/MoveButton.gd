class_name MoveButton extends BaseButton

var move:Move = null

signal move_selected(move)

func _ready():
	pass # Replace with function body.

func setMove(move:Move) -> void:
	self.move = move
	if move:
		self.text = move.getMoveName()
	else:
		self.text = ""
	
func _pressed() -> void:
	move_selected.emit(move)
