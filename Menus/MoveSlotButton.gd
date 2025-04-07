class_name MoveSlotButton extends MoveButton

#a move button that can always be selected. Usually used in menus to change movesets

func setMove(move:Move):
	super(move)
	if move:
		self.text = move.getMoveName()
	else:
		self.text = ""
		
func _process(delta) -> void:
	#disabled = false
	pass
	
