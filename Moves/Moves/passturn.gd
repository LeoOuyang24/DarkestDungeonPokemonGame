class_name PassTurn extends Move

#an empty move that just passes the turn

func _init():
	moveName = "Pass Turn"
	summary = "Skip turn."
	icon = load("res://sprites/icons/moves/move_pass_turn.png")
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await UI.get_tree().create_timer(0.5).timeout
