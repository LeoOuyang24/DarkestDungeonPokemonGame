extends PanelContainer

signal horror_created(creature:Creature)


@onready var CreateButton = %Create
@onready var Grid = %Grid;

var TeamSlot = preload("res://Menus/CreateHorrorButton.tscn")
#cost to create a creature, permanently increases every time a creature is made
static var globalCost:int = 5; 
var selected:Creature = null
# Called when the node enters the scene tree for the first time.
func _ready():
	CreateButton.setCost(globalCost)
	createSlots()
	pass # Replace with function body.

func createSlots():
	var margin = Vector2(0.1*size.x,0.3*size.y)
	var perRow = 7
	var known = ["Beholder","Chomper","Silent"]#Game.PlayerState.scans
	for i in range(known.size()):
		var creature:Creature = CreatureLoader.loadJSON(CreatureLoader.CreatureJSONDir + known[i] + ".json")
		var slot = TeamSlot.instantiate()
		Grid.add_child(slot)
		
		slot.creature = creature
		slot.get_node("Button").pressed.connect(set.bind("selected",creature))

func _on_create_pressed():
	globalCost *= 2
	horror_created.emit(selected)
	CreateButton.setCost(globalCost)
	pass # Replace with function body.
