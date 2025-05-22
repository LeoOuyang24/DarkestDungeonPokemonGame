class_name ApplyShock extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Apply Shock",1,2)
	summary = "Apply shock equal to 1x damage to a target"
	icon = load("res://sprites/statuses/shock.png")
	pass # Replace with function body.

func move(user:Creature,targets:Array,battle:Battlefield):
	if user and targets.size() > 0:
		var target = battle.getCreature(targets[0])
		if target:
			battle.events.applyStatus(user,target,Shock.new(),user.stats.getCurStat(CreatureStats.STATS.ATTACK))
	
	
