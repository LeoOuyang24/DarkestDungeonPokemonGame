extends InBattleSummary


func setCurrentCreature(creature:Creature, disableButtons:bool) -> void:
	super(creature,disableButtons)
	
	PassButton.visible = false
	Moves.disableMoves(disableButtons)
