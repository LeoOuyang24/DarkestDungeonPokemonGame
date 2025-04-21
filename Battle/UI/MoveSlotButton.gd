class_name MoveSlotButton extends MoveButton

#a move button that is concerned with MoveSlots
#so if a move is not usable because its on cooldown, this button will turn off

var slot:MoveSlot = null

func setSlot(newSlot:MoveSlot, creature:Creature) -> void:
	if slot:
		slot.cooldown_changed.disconnect(update)
	
	self.slot = newSlot
	self.creature = creature
	
	if slot:
		setMove(slot.move,creature)


#THIS WILL OVERRIDE THE MOVE IN THE CREATURE'S SLOT
func setMove(move:Move,creature_:Creature = null) -> void:
	#this should really only occur if this button is not associated 
	#with a creature
	#PassTurn is a good example of when that would happen
	if !slot: 
		var newSlot:MoveSlot = MoveSlot.new()
		newSlot.move = move
		#this weird recursion where we go to setSlot and then back to setMove
		#ensures that any setSlot specific stuff (disconnecting signals)
		#and setMove stuff (connecting signal) all gets done
		setSlot(newSlot,creature_)
	else:
		#ensures we emit the right move when pressed
		#a bit redundant to have slot.move and self.move
		self.move = move 
		slot.move = move
		slot.cooldown_changed.connect(update.unbind(2))
		update()


func getMove() -> Move:
	return slot.getMove() if slot else null

func _make_custom_tooltip(summary:String):
	if slot:
		return getMoveTooltip(slot.getMove(),creature)
	return ""

#update button to changes to move
func update() -> void:
	if slot:
		if slot.isUsable():
			self.text = slot.getMove().getMoveName()
			self.disabled = false
		else:
			self.text = str(slot.getRemainingCD()) if slot.move else ""
			self.disabled = true
	else:
		self.text = ""
	
