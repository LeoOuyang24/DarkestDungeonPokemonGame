extends ColorRect

signal horror_created(creature:Creature)


# Called when the node enters the scene tree for the first time.
func _ready():
	createSlots()
	pass # Replace with function body.

func createSlots():
	var margin = Vector2(0.1*size.x,0.1*size.y)
	var perRow = 7
	var known = ["Beholder","Chomper","Silent"]#Game.PlayerState.scans
	for i in range(known.size()):
		var creature = CreatureLoader.loadJSON(CreatureLoader.CreatureJSONDir + known[i] + ".json")
		var slot = AnimatedButton.new()
		#slot.setCreature(creature)
		slot.position.x = margin.x*((i)%perRow + 1)
		slot.position.y = margin.y*((i)/perRow + 1)
		#anime.play()
		slot.setSprite(creature.getSprite())
		slot.setSize(Vector2(100,100))
		slot.pressed.connect(func():
			horror_created.emit(creature)
			)
		slot.disabled = Game.GameState.getDNA() < 10
		add_child(slot)
		Game.GameState.DNA_changed.connect( func(amount):
			slot.disabled = Game.GameState.getDNA() < 10
			)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
