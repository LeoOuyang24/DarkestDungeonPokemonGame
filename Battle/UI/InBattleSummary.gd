extends Control

var creature:Creature = null

signal move_selected(move:Move);

@onready var PassButton = %PassButton;
@onready var Moves = %Moves.get_children() + [PassButton];
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
	self.creature = creature
	%CreatureStats.setCreature(creature)
	
	#if is an enemy or a non-current ally...
	#disable all buttons
	if creature:
		for mov:int in range(Moves.size()):
			#disable the button if the creature is not current or if its already disabled for whatever reason
			#we skip the passbutton. If the Passbutton is ever disabled, it can never be reenabled.
			var moveButton:MoveButton = Moves[mov]
			if moveButton != PassButton:
				moveButton.setMove(creature.getMove(mov),creature)
				moveButton.disabled = moveButton.disabled || !creature.getIsFriendly() || !isCurrent 
			else:
				#for the passbutton, the disabled is purelly based on whether the creature is current or not
				moveButton.disabled = !isCurrent;
		PassButton.visible = creature.getIsFriendly() #pass can be straight up skipped if the creature is an enemy
