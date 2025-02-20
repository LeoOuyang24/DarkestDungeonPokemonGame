extends ColorRect

@onready var TeamSlotsRect = $TeamSlotsRect
@onready var CreatureSummary = $CreatureSummary
@onready var CreateHorror = $CreateHorror

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in TeamSlotsRect.get_children():
		i.pressed.connect(viewSummary.bind(i))
	GameState.PlayerState.team_changed.connect(func ():
		updateTeamSlots(GameState.PlayerState.getTeam())
		)
	pass # Replace with function body.

#update the team state
#if we are lacking UI slots, add more
#if we have too many UI slots, remove them
func updateTeamSlots(allies):
	#add player to UI
	#PlayerSlot.setCreature(player)
	#add allies, adding any necessary slots in the process
	
	for i in range(TeamSlotsRect.get_children().size()):
		var creature = allies[i] if i < allies.size() else null
		var slot = TeamSlotsRect.get_children()[i]
		slot.setCreature(creature)
	
func viewSummary(teamSlot:CreatureSlot):
	if teamSlot.getCreature():
		CreatureSummary.setCreature(teamSlot.getCreature())
		if CreateHorror.position.x >= size.x: #if CreateHorror tab is out, move it back
			var tween := create_tween()
			tween.tween_property(CreateHorror,"position",Vector2(size.x - CreateHorror.size.x,0),.5)
	else:
		var tween := create_tween()
		tween.tween_property(CreateHorror,"position",Vector2(size.x,0),.5)
		#CreatureSummary.visible = false
		
func _on_create_horror_horror_created(creature:Creature):
	GameState.PlayerState.addCreatureToTeam(creature)
	pass # Replace with function body.


func _on_create_horror_horror_selected(creature:Creature):
	CreatureSummary.setCreature(creature)	
	pass # Replace with function body.
