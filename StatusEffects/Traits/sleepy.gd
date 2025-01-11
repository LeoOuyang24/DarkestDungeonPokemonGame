class_name Sleepy extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Sleepy"
	tooltip = "Creature starts every combat with 3 turns of Sleep."
		
func inBattle(battle:Battlefield) -> void:
	creature.statuses.addStatus(Sleep.new(),3);
	
