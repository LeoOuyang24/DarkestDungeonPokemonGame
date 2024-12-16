class_name CostComponent extends Node

signal cost_changed(newCost:int)

#emitted when affordability status changes, true if can afford now, false if can no longer afford
signal can_afford(not_broke:bool) 

#add to buttons that have a cost
#if the player can't afford, the button is disabled

@export var cost:int = 0:
	set(value):
		cost = value;
		cost_changed.emit(value)
		updateDisabled()
		
var parent:Button = null

func _ready():
	parent = get_parent() as Button #attempt to get the parent button
	if parent:
		parent.pressed.connect(func(): #when pressed, apply the cost
			GameState.setDNA(GameState.getDNA() - cost))
		await parent.ready
		updateDisabled()
	GameState.DNA_changed.connect(updateDisabled)
	pass # Replace with function body.

#disable/enable parent based on dna changes
func updateDisabled(_amount=0):
	if (parent):
		var old := parent.is_disabled()
		parent.set_disabled(GameState.getDNA() < cost);
		if old != parent.is_disabled():
			can_afford.emit(GameState.getDNA() >= cost)
		
