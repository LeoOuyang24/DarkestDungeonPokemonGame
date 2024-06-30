extends Node2D

@onready var TeamSlotsRect = $TeamSlotsRect
@onready var PlayerSlot = $PlayerSlot
@onready var TeamSlots = []
@onready var CreatureSummary = $CreatureSummary

var CreatureSlotScene = preload("res://Battle/UI/CreatureSlot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#update the team state
#if we are lacking UI slots, add more
#if we have too many UI slots, remove them
func updateTeamSlots(player,allies):
	#add player to UI
	#PlayerSlot.setCreature(player)
	#add allies, adding any necessary slots in the process
	allies = [player] + allies
	for i in range(allies.size()):
		if i>= TeamSlots.size():
			addTeamSlot()
		TeamSlots[i].setCreature(allies[i])
	#remove any excess slots
	for i in range(TeamSlots.size() - allies.size()):
		TeamSlots[i].remove_at(allies.size() + i)
	
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
	slot.set_script(load("res://Menus/TeamViewSlot.gd"))
	slot.pressed.connect(func():
		viewSummary(slot)
		)
	TeamSlots.push_back(slot)
	TeamSlotsRect.add_child(slot)

	
func viewSummary(teamSlot:CreatureSlot):
	if teamSlot.getCreature():
		CreatureSummary.visible = true
		CreatureSummary.setCreature(teamSlot.getCreature())
	else:
		CreatureSummary.visible = false
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
