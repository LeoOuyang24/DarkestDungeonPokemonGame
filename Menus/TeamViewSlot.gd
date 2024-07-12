class_name TeamViewSlot extends CreatureSlot

#renders a Creature in the team menu

# Called when the node enters the scene tree for the first time.
func _ready():
	Sprite.flip_h = true
	pass # Replace with function body.

func setCreature(creature:Creature) -> void:
	super(creature)
	if !creature:
		#var texture = load("res://sprites/UI/empty_creatureslot.tres")
		#print(texture.get_frame_count("default"))
		setSprite(load("res://sprites/UI/empty_creatureslot.tres"))
		#Sprite.animation = "default"
		#Sprite.play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if creature:
		if (!creature.isAlive()):
			modulate = Color.DARK_RED
			HealthBar.label.set_text("DEAD") 
			HealthBar.label.modulate = Color.BLACK
			Sprite.stop()

