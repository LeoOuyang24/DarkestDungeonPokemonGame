extends ColorRect

@onready var CreatureName:Label = %"Creature Name"
@onready var Sprite:Anime = %Anime

func setCreature(creatureName:StringName):

	var creature:Creature = CreatureLoader.loadJSON(creatureName)
	
	CreatureName.set_text(creature.getName())
	Sprite.setSprite(creature.getSprite())
	
