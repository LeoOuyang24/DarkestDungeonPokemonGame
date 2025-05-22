class_name Slash extends GenericAttack

func _init():
	super("Slash",0,1,"Deal 0.5x damage to two frontmost targets")
	icon = load("res://sprites/icons/moves/move_slash.png")


	
func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(2,user.getIsFriendly())

func getMult() -> float:
	return 0.5
