extends GridContainer


signal move_selected(move:Move,button:MoveButton)

#generic scene for collection of 4 moves that every creature has, not including PassTurn

@onready var Moves:Array[Node] = get_children()
@export var moveSlots:bool = false #true if the moves are moveSlotButtons

const moveSlotsScript := preload("res://Battle/UI/MoveSlotButton.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Moves:
		if i:
			i.pressed.connect(func() -> void:
				move_selected.emit(i.getMove(),i)			
				)
		if moveSlots:
			i.set_script(moveSlotsScript)
	pass # Replace with function body.

#set the moves equal to that of a creature

func setMoves(creature:Creature) -> void:
	if creature:
		for i in range(Creature.maxMoves):
			var butt := Moves[i] as MoveButton
			if moveSlots:
				butt.setSlot(creature.getMoveSlot(i),creature)
			else:
				butt.setMove(creature.getMove(i),creature)
			
#"disable" is true if we want to disable all buttons, false otherwise if we want to enable all of them
#if "useOld" is true, the button is only enabled if it currently is already enabled
#basically if the button is disabled by some other means, we won't accidentally renable it
func disableMoves(disable:bool,useOld:bool = false) -> void:
	for i in Moves:
		i.disabled = (!useOld and disable) or (useOld and (disable or i.disabled))
