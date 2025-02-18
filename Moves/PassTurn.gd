class_name PassTurn extends Move

#an empty move that just passes the turn

func _init():
	moveName = "Pass Turn"
	summary = "Skip the turn like the coward you are."
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await UI.get_tree().create_timer(1.0).timeout
