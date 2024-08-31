class_name Shoot extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Shoot",1,10)
	summary = "Deal %s damage to a chosen target"
	pass # Replace with function body.
func getModifiers(user:Creature) -> Array:
	return [{"value":user.stats.getCurStat(CreatureStats.STATS.ATTACK),"color":Color.RED,"calc":"1x"}]

func move(user:Creature, enemies:Array, battlefield):
	if len(enemies) > 0: #just to be safe, make sure we are actually targeting something

		Creature.dealDamage(user,battlefield.getCreature(enemies[0]),user.stats.getCurStat(CreatureStats.STATS.ATTACK)); #realistically the player should only be targeting one enemy, but even if they target multiple, we only hit the first
	pass
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
