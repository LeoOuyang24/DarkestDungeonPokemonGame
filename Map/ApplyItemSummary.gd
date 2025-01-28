extends Control

#virtually the same as InBattleSummary except we remvoed PassButton

var creature:Creature = null

signal move_selected(move:Move);

@onready var Moves = %Moves.get_children();
#in-battle creature summary


func _ready():
	for i in Moves:
		i.move_selected.connect(func (move):
			move_selected.emit(move)
		)
	

#sets the current creature, which is rendered differently based on whether or not the creature is current or not
#and whether or not it is friendly
func setCreature(creature:Creature) -> void:
	%CreatureStats.setCreature(creature)
	
	#if is an enemy or a non-current ally...
	#disable all buttons
	if creature:
		for mov:int in range(Moves.size()):
			#disable the button if the creature is not current or if its already disabled for whatever reason
			#we skip the passbutton. If the Passbutton is ever disabled, it can never be reenabled.
			var moveButton:MoveButton = Moves[mov]
			moveButton.setMove(creature.getMove(mov),creature)
	
