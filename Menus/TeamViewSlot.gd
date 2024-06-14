class_name TeamViewSlot extends CreatureSlot

#renders a Creature in the team menu


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!creature.isAlive()):
		modulate = Color.DARK_RED
		HealthBar.label.set_text("DEAD") 
		HealthBar.label.modulate = Color.BLACK
		Sprite.stop()

