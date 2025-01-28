extends MarginContainer

@onready var Stats := [%Health,%Attack,%Speed]

func setCreature(creature:Creature) -> void:
	%Sprite.setCreature(creature)
	#add stats to UI
	for i in range(Stats.size()):
		Stats[i].setCreature(creature,i)
