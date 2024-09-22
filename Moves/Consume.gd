class_name Consume extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Consume",1,5)
	summary = "Kill an ALLY. Gain a portion of their BASE stats."
	targetingCriteria = Move.TARGETING_CRITERIA.ONLY_ALLIES;
	pass # Replace with function body.


func postMoveMessage(user:Creature, targets:Array, battlefield:Battlefield) -> String:
	if len(targets) > 0 && battlefield.getCreature(targets[0]) == self:
		return "Can't consume self!"
	return ""
		

func move(user:Creature, targets:Array, battlefield):
	if len(targets) > 0: #just to be safe, make sure we are actually targeting something
		var target = battlefield.getCreature(targets[0])
		if target != self:
			target.stats.getStatObj(CreatureStats.STATS.HEALTH).setStat(0);
			
			user.stats.forEachStat(func(stat:CreatureStats.STATS, statObj:Stat):
				statObj.addBaseStat(0.5*target.stats.getStatObj(stat).getBaseStat()) #gain half their base stats
				)
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
