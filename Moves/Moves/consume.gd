class_name Consume extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Consume",1,5)
	summary = "Kill an ALLY. Gain a portion of their BASE stats."
	targetingCriteria = Move.TARGETING_CRITERIA.OTHER_ALLIES;
	pass # Replace with function body.


func postMoveMessage(user:Creature, targets:Array, battlefield:Battlefield) -> String:
	if len(targets) > 0 && battlefield.getCreature(targets[0]) == self:
		return "Can't consume self!"
	return ""
		

func move(user:Creature, targets:Array, battlefield):
	if len(targets) > 0: #just to be safe, make sure we are actually targeting something
		var target = battlefield.getCreature(targets[0])
		if target != self:
			battlefield.events.changeStat(target,CreatureStats.STATS.HEALTH,0,false,user);			
			user.stats.forEachStat(func(stat:CreatureStats.STATS, statObj:Stat):
				battlefield.events.changeStat(user,stat,0.5*target.stats.getStatObj(stat).getBaseStat(),true,self)
				)
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
