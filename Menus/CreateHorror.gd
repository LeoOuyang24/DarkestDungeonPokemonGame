extends PanelContainer

signal horror_created(creature:Creature)
signal horror_selected(creature:Creature)

@onready var CreateButton = %Create
@onready var Grid = %Grid;

var TeamSlot = preload("res://Menus/CreateHorrorButton.tscn")
#cost to create a creature, permanently increases every time a creature is made
static var globalCost:int = 5; 

var selected:Creature = null:
	set(value):
		selected = value
		CreateButton.disable = value == null 
# Called when the node enters the scene tree for the first time.
func _ready():
	CreateButton.cost = globalCost
	selected = null
	createSlots()
	GameState.PlayerState.added_scan.connect(addScan)
	pass # Replace with function body.

func addScan(name:String):
	var creature:Creature = CreatureLoader.loadJSON(CreatureLoader.CreatureJSONDir + name + ".json")
	var slot = TeamSlot.instantiate()
	Grid.add_child(slot)
	
	slot.creature = creature
	slot.get_node("Button").pressed.connect(onCreatureSelect.bind(creature))

func createSlots():
	var margin = Vector2(0.1*size.x,0.3*size.y)
	var perRow = 7
	var known = GameState.PlayerState.scans
	for i in range(known.size()):
		addScan(known[i])

func onCreatureSelect(creature:Creature):
	selected = creature
	horror_selected.emit(creature)

func _on_create_pressed():
	globalCost *= 2
	horror_created.emit(selected)
	CreateButton.cost = globalCost
	selected = null
	pass # Replace with function body.
