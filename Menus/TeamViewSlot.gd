class_name TeamViewSlot extends CreatureSlot

#renders a Creature in the team menu
#size does not change

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	onHoverOutline=true
	#size_flags_vertical = SIZE_SHRINK_END
	#flip_h = true
	pass # Replace with function body.

func setCreature(creature:Creature) -> void:
	super(creature)
	if !creature:
		#var texture = load("res://sprites/UI/empty_creatureslot.tres")
		#print(texture.get_frame_count("default"))
		setSprite(load("res://sprites/UI/empty_creatureslot.tres"))
		Resources.resize(Vector2(150,150),self)

	#size is 150x150
	#Resources.resize(Vector2(150,150),self)
	#setSize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	if creature:
		if (!creature.isAlive()):
			modulate = Color.DARK_RED
			HealthBar.label.set_text("DEAD") 
			HealthBar.label.modulate = Color.BLACK
			sprite.pause()
