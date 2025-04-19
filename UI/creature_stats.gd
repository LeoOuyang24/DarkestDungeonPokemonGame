extends MarginContainer

@onready var Stats := [%Health,%Attack,%Speed]
@onready var Name := %Name

#set the name and level of creature
func setLabel(creature:Creature):
	Name.set_text(str(creature.getName()) + "\nLevel "+str(creature.getLevel()))
	Name.creature = creature


func setCreature(creature:Creature) -> void:
	%Sprite.setSprite(creature.getSprite())
	setLabel(creature)
	#add stats to UI
	for i in range(Stats.size()):
		Stats[i].setCreature(creature,i)

func forEachStat(callable:Callable) -> void:
	for i in Stats:
		callable.call(i)
