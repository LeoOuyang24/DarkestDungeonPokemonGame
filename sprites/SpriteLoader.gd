extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#maps filepaths to loaded sprites
var sprites = {}

func getSprite(str:String) -> SpriteFrames:
	var sprite = load("res://sprites" + "/" + str + ".tres")
	if sprite:
		return sprite;
	else:
		#try again with all lowercase
		sprite = load("res://sprites" + "/" + str.to_lower() + ".tres")
		if sprite:
			return sprite
		else:
			push_error("failed to load spritesheet for " + str);
			return null
	
