class_name Slash extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	manualTargets = 0;
	moveName="Slash"
	summary="Deal 0.5x damage to two frontmost targets"
	
func runAnimation(user:Creature, enemies: Array, UI:BattleUI,battlefield:Battlefield) -> void:
	if enemies.size() > 0:
		await MoveAnimations.genericAttackAnimation(user,[enemies[0]],UI,self,1.5)
	
func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(2,user.getIsFriendly())

	
func move(user, targets, battlefield):
	#var arr = battlefield.getEnemies(user.getIsFriendly()) 
	#var count = 0
	for i in targets:
		var target = battlefield.getCreature(i)
		if target:
			Creature.dealDamage(user,target,user.stats.getCurStat(CreatureStats.STATS.ATTACK)/2);
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
