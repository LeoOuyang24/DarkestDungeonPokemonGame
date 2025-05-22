class_name Bite extends GenericAttack

# Called when the node enters the scene tree for the first time.
func _init():
	super("Bite",0,1,"Deal 1x damage to frontmost target")

func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(1,user.getIsFriendly())
