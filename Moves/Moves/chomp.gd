class_name Chomp extends GenericAttack


# Called when the node enters the scene tree for the first time.
func _init():
	super("Chomp",0,1,"Deal %s damage to frontmost target")


func getMult() -> float:
	return 1.5

func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(1,user.getIsFriendly())



	
