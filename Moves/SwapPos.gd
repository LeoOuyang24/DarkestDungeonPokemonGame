class_name SwapPos extends Move



func _init():
	moveName = "Tactic: Swap"
	manualTargets = 1
	targetingCriteria=Move.TARGETING_CRITERIA.ONLY_ALLIES

func move(user:Creature, targets:Array, battlefield):
	battlefield.swapCreature(battlefield.getCreatureIndex(user),targets[0])

func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield):
	var slot = UI.getCreatureSlot(user)
	var enemySlot = UI.getCreatureSlot(targets[0])
	
	slot.getTween().tween_property(slot,"global_position",enemySlot.global_position,0.5)
	var tween = enemySlot.getTween().tween_property(enemySlot,"global_position",slot.global_position,0.5)
	await tween.finished
	
