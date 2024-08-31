extends ColorRect

signal horror_created(creature:Creature)

var TeamSlot = preload("res://Menus/TeamViewSlot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	createSlots()
	pass # Replace with function body.

func createSlots():
	var margin = Vector2(0.1*size.x,0.3*size.y)
	var perRow = 7
	var known = ["Beholder","Chomper","Silent"]#Game.PlayerState.scans
	for i in range(known.size()):
		var creature:Creature = CreatureLoader.loadJSON(CreatureLoader.CreatureJSONDir + known[i] + ".json")
		var slot = CreateHorrorButton.new()

		add_child(slot)
		


		slot.position.x = margin.x*((i)%perRow + 1)
		slot.position.y = margin.y*((i)/perRow + 1)
		slot.setCreature(creature)

		slot.pressed.connect(func():
			horror_created.emit(creature)
			slot.updateDisabled()
			)

		GameState.DNA_changed.connect( func(amount):
			slot.disabled = GameState.getDNA() < 10
			)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
