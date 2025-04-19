class_name Brutalize extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Brutalize",0,2)
	targetingCriteria = TARGETING_CRITERIA.ONLY_ENEMIES
	icon = load("res://sprites/icons/moves/fist.png")
	summary = "Deal 1.3x damage to frontmost and rearmost enemy, but user loses attack"
	pass # Replace with function body.

func getPreselectedTargets(user:Creature, battle:Battlefield):
	if battle.getEnemies(user.getIsFriendly(),false).size() == 1:
		return battle.getFrontMostCreatures(1,user.getIsFriendly())
	var targets = battle.getFrontMostCreatures(1,user.getIsFriendly()) + battle.getFrontMostCreatures(-1,user.getIsFriendly())
	return targets

func move(user:Creature, targets:Array, battlefield):
	var damage = user.stats.getCurStat(CreatureStats.STATS.ATTACK)*1.3
	for target in targets:
		var c = battlefield.getCreature(target)
		if c:
			Creature.dealDamage(user,c,damage)
			
	if targets.size() > 0:
		user.statuses.addStatus(AddStatEffect.new(CreatureStats.STATS.ATTACK,-1),-0.5*user.stats.getBaseStat(CreatureStats.STATS.ATTACK))

	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
