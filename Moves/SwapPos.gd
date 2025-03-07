class_name SwapPos extends Move



func _init():
	moveName = "Tactic: Swap"
	icon = load("res://sprites/icons/speed_icon.png")
	manualTargets = 1
	targetingCriteria=Move.TARGETING_CRITERIA.OTHER_ALLIES
	summary = "Swap position with an ally"

func move(user:Creature, targets:Array, battlefield):
	battlefield.swapCreature(battlefield.getCreatureIndex(user),targets[0])
#	await UI.AllyRow.sort_children


func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield):
	var slot = UI.getCreatureSlot(user)
	var enemySlot = UI.getCreatureSlot(targets[0])
	
	await UI.swapSlots(slot,enemySlot)
	
