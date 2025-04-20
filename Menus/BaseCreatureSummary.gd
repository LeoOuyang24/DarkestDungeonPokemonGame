class_name BaseCreatureSummary extends Control

signal move_selected(move:Move);

@onready var Stats = %CreatureStats
@onready var Moves = %Moves

var creature:Creature = null
#in-battle creature summary

func _ready():
	Moves.move_selected.connect(func(move:Move,_butt) -> void:
		move_selected.emit(move)
		)

#sets the current creature, which is rendered differently based on whether or not the creature is current or not
#and whether or not it is friendly
func setCurrentCreature(creature:Creature, isCurrent:bool) -> void:
	if self.creature:
		self.creature.move_changed.disconnect(Moves.setMoves)
	self.creature = creature
	Stats.setCreature(creature)	
	
	#if is an enemy or a non-current ally...
	#disable all buttons
	if creature:
		creature.move_changed.connect(Moves.setMoves.bind(creature).unbind(2))
		Moves.setMoves(creature)
