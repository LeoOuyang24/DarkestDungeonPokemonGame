class_name Silence extends Move


	
func _init():
	manualTargets = 1;
	moveName="Silence"
	summary="Remove all buffs from a creature"
	
func runAnimation(user:Creature, enemies: Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,enemies,UI,self)

	
func move(user, targets, battlefield):
	if targets.size() > 0:
		var statusManager = battlefield.getCreature(targets[0]).statuses
		var statuses = statusManager.getAllStatuses()
		for statusName in statuses:
			if !statuses[statusName].getIsDebuff():
				statusManager.removeStatus(statuses[statusName])
