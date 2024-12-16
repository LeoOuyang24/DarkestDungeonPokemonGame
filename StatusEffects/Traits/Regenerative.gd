class_name Regenerative extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Regenerative"
	tooltip="Creature regains 2 health at the start of turn."


#what to do at end of turn
#by default, remove one stack
func newTurn() -> void:
	if creature:
		creature.stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(2)
		
func onAddUI(slot:Control) -> void:
	slot.add_child(load("res://sprites/effects/animations/sparkles.tscn").instantiate())
	
func onRemoveUI(slot:Control) -> void:
	for i in slot.get_children():
		if i.name == "Sparkles":
			slot.remove_child(i)
			break
