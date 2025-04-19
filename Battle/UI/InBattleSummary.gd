class_name InBattleSummary extends Control

#var creature:Creature = null

signal move_selected(move:Move);

@onready var Stats = %CreatureStats
@onready var PassButton = %PassButton;
@onready var Moves = %Moves

var creature:Creature = null
#in-battle creature summary

func _ready():
	Moves.move_selected.connect(func(move:Move,_butt) -> void:
		move_selected.emit(move)
		)
	
	if PassButton:
		PassButton.setMove(PassTurn.new())
		PassButton.move_selected.connect(move_selected.emit)

#sets the current creature, which is rendered differently based on whether or not the creature is current or not
#and whether or not it is friendly
func setCurrentCreature(creature:Creature, isCurrent:bool) -> void:
	self.creature = creature
	Stats.setCreature(creature)	
	
	#if is an enemy or a non-current ally...
	#disable all buttons
	if creature:
		creature.move_changed.connect(func(_i,_m):
			Moves.setMoves(creature))
		#disable the button if the creature is not current or if its already disabled for whatever reason
		#and we are in battle
		Moves.setMoves(creature)
		Moves.disableMoves((!creature.getIsFriendly() || !isCurrent) && GameState.getBattle(),true)

		#for the passbutton, the disabled is purelly based on whether the creature is current or not
		if PassButton:
			PassButton.creature = creature #this allows proper updating of the button
			PassButton.disabled = !isCurrent
			#PassButton.visible = creature.getIsFriendly() 
