extends ColorRect

@onready var CreatureName:Label = %"Creature Name"
@onready var Sprite:Anime = %Anime

func setCreature(creatureName:StringName):

	var creature:Creature = CreatureLoader.loadJSON(CreatureLoader.CreatureJSONDir + creatureName + ".json")
	
	CreatureName.set_text(creature.getName())
	Sprite.setSprite(creature.getSprite())
	
