extends Node2D

@onready var TeamSlotsRect = $TeamSlotsRect
@onready var PlayerSlot = $PlayerSlot
@onready var TeamSlots = []
@onready var CreatureSummary = $CreatureSummary
@onready var CreateHorror = $CreateHorror

var CreatureSlotScene = preload("res://Battle/UI/CreatureSlot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Battlefield.maxAllies):
		addTeamSlot()
	Game.PlayerState.team_changed.connect(func ():
		updateTeamSlots(Game.PlayerState.getPlayer(),Game.PlayerState.getTeam())
		)
	pass # Replace with function body.

#update the team state
#if we are lacking UI slots, add more
#if we have too many UI slots, remove them
func updateTeamSlots(player,allies):
	#add player to UI
	#PlayerSlot.setCreature(player)
	#add allies, adding any necessary slots in the process
	allies = [player] + allies
	for i in range(TeamSlots.size()):
		var creature = allies[i] if i < allies.size() else null
		TeamSlots[i].setCreature(creature)
	
#add a new teamslot
#adds to the end of TeamSlots
func addTeamSlot():
	var slot = CreatureSlotScene.instantiate()

	var size = TeamSlotsRect.get_size()
	#var sideMargin = 0.1*size.x
	var slotPadding = 0.1*size.x
	
	var topMargin = 0.1*size.y
	var topPadding = 0.25*size.y
	
	slot.position = Vector2(slotPadding*2*(TeamSlots.size()), 
							topMargin)
	#TODO: Maybe change this to not have to hardcode the icons?
	#maybe create a TeamViewSlot scene
	slot.set_script(load("res://Menus/TeamViewSlot.gd"))
	slot.get_node("Icons").set_visible(false)
	slot.pressed.connect(func():
		viewSummary(slot)
		)
	TeamSlots.push_back(slot)
	TeamSlotsRect.add_child(slot)

	
func viewSummary(teamSlot:CreatureSlot):
	if teamSlot.getCreature():
		CreateHorror.visible = false
		CreatureSummary.visible = true
		CreatureSummary.setCreature(teamSlot.getCreature())
	else:
		CreateHorror.visible = true
		CreatureSummary.visible = false
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_horror_horror_created(creature):
	Game.PlayerState.addCreatureToTeam(creature)
	pass # Replace with function body.
