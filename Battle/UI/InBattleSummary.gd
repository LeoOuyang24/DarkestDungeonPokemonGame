class_name InBattleSummary extends CreatureSummary


signal move_selected(move:Move);

@onready var PassButton = %PassButton;
@onready var Moves = %LearnNewMove.Moves + [PassButton];
#in-battle creature summary


func _ready():
	for i in Moves:
		i.move_selected.connect(func (move):
			move_selected.emit(move)
		)
	
	PassButton.setMove(PassTurn.new(),null)


#sets the current creature, which is rendered differently based on whether or not the creature is current or not
#and whether or not it is friendly
func setCurrentCreature(creature:Creature, isCurrent:bool) -> void:
	setCreature(creature)
	#if is an enemy or a non-current ally...
	#disable all buttons
	for moveButton:Button in Moves:
		#disable the button if the creature is not current or if its already disabled for whatever reason
		#we skip the passbutton. If the Passbutton is ever disabled, it can never be reenabled.
		if moveButton != PassButton:
			moveButton.disabled = moveButton.disabled || !creature.getIsFriendly() || !isCurrent 
		else:
			#for the passbutton, the disabled is purelly based on whether the creature is current or not
			moveButton.disabled = !isCurrent;
	PassButton.visible = creature.getIsFriendly() #pass can be straight up skipped if the creature is an enemy

