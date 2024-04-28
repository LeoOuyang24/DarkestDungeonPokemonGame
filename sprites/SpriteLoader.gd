extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#maps filepaths to loaded sprites
var sprites = {}

func get_sprite(str:String) -> SpriteFrames:
	var sprite = load("res://sprites" + "/" + str + ".tres")
	if sprite:
		return sprite;
	else:
		push_error("failed to load spritesheet for " + str);
		return null
	
