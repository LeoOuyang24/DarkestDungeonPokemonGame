class_name InBattleSummary extends BaseCreatureSummary

#var creature:Creature = null


@onready var PassButton = %PassButton;

#in-battle creature summary

func _ready():
	super()
	if PassButton:
		PassButton.setMove(PassTurn.new())
		PassButton.move_selected.connect(move_selected.emit)

#sets the current creature, which is rendered differently based on whether or not the creature is current or not
#and whether or not it is friendly
func setCurrentCreature(creature:Creature, isCurrent:bool) -> void:
	super(creature,isCurrent)

	Moves.disableMoves(!isCurrent,true)

	#for the passbutton, the disabled is purelly based on whether the creature is current or not
	if PassButton:
		PassButton.disabled = !isCurrent
