class_name GigaImpact extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Maul",1,2)
	targetingCriteria = TARGETING_CRITERIA.ONLY_ENEMIES
	icon = load("res://sprites/icons/moves/fist.png")
	summary = "Deal 1.8x damage, but user can not attack next turn"
	pass # Replace with function body.

func move(user:Creature, targets:Array, battlefield):
	var damage = user.stats.getCurStat(CreatureStats.STATS.ATTACK)*1.8
	print(targets)
	print(battlefield.getCreature(targets[0]))
	if targets.size() > 0 and battlefield.getCreature(targets[0]):
		print(targets)
		print(battlefield.getCreature(targets[0]))
		Creature.dealDamage(user,battlefield.getCreature(targets[0]),damage)
		user.statuses.addStatus(Dazed.new(),2)

	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
