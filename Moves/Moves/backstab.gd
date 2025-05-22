class_name Backstab extends GenericAttack


# Called when the node enters the scene tree for the first time.
func _init():
	super("Backstab",0,1,"Deal %s damage to rearmost target")
	icon = load("res://sprites/icons/moves/move_stab.png")

	pass # Replace with function body.

func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(-1,user.getIsFriendly())

func getMult():
	return 1.5;
	
	
