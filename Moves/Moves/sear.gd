class_name Sear extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Sear",1,2)
	summary = "Apply burn equal to 0.5x damage to a target"
	pass # Replace with function body.

func move(user:Creature,targets:Array,battle:Battlefield):
	if user and targets.size() > 0:
		var target = battle.getCreature(targets[0])
		if target:
			battle.events.applyStatus(user,target,Burn.new(),user.stats.getCurStat(CreatureStats.STATS.ATTACK)*0.5)
	
	
