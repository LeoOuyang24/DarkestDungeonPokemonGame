class_name Slam extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	super("Slam",0,10)
	
	summary="Deal 1.5x damage to frontmost target. Excess damage passes to the next creature."
	
func runAnimation(user:Creature, enemies: Array, UI:BattleUI,battlefield:Battlefield) -> void:
	if enemies.size() > 0:
		await MoveAnimations.genericAttackAnimation(user,[enemies[0]],UI,self,1.5)
	
#technically this move can hit all enemies
func getPreselectedTargets(user:Creature, battle:Battlefield):
	if user:
		return battle.getEnemies(user.getIsFriendly())
	return []

	
func move(user, targets, battlefield):
	#var arr = battlefield.getEnemies(user.getIsFriendly()) 
	#var count = 0
	var damage = user.stats.getCurStat(CreatureStats.STATS.ATTACK)*1.5
	for target in targets:
		if target:
			var damageDealt := Creature.dealDamage(user,target,damage);
			if !target.isAlive() and damage > damageDealt: #if creature died and there's excess damage left, move to the next target
				damage -= damageDealt
			else:
				break
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
