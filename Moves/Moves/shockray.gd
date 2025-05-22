class_name ShockRay extends GenericAttack

func _init():
	super("Shock Ray",0,1,"Apply 0.35x damage worth of shock to front two enemies")
	icon = load("res://sprites/statuses/shock.png")


	
func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(2,user.getIsFriendly())

func getMult() -> float:
	return 0.0

func extras(user:Creature,target:Creature,battle:Battlefield) -> void:
	if target and user:
		battle.events.applyStatus(user,target,Shock.new(),user.stats.getCurStat(CreatureStats.STATS.ATTACK)*0.35)
