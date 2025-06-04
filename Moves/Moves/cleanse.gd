class_name Cleanse extends Move
	
func _init():
	manualTargets = 1;
	moveName="Cleanse"
	summary="Remove all debuffs from a creature"
	icon = load("res://sprites/icons/moves/move_purify.png")
	targetingCriteria = TARGETING_CRITERIA.OTHER_ALLIES
	
var effect := preload("res://sprites/spritesheets/moves/soporifics.tres")
	
func runAnimation(user:Creature, enemies: Array, UI:BattleUI,battlefield:Battlefield) -> void:
	if enemies.size() > 0:
		var slot = UI.getCreatureSlot(enemies[0])
		if slot:
			var effect = AnimeEffect.createEffectOnControl(effect,slot,1,!user.getIsFriendly());
			await effect.finished

	
func move(user, targets, battlefield):
	if targets.size() > 0:
		var creature:Creature = battlefield.getCreature(targets[0])
		if creature:
			var statusManager = creature.statuses
			var statuses = statusManager.getAllStatuses()
			for statusName in statuses:
				if statuses[statusName].getIsDebuff():
					battlefield.events.removeStatus(user,creature,statusName)
					#statusManager.removeStatus(statuses[statusName])
