class_name MinorScramble extends Move



func _init():
	moveName = "Minor Scramble"
	icon = load("res://sprites/icons/speed_icon.png")
	manualTargets = 0
	targetingCriteria=Move.TARGETING_CRITERIA.ONLY_ENEMIES
	summary = "Swap positions of the front two enemies"

func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(2,user.getIsFriendly())


func move(user:Creature, targets:Array, battlefield):
	if targets.size() == 2:
		battlefield.swapCreature(targets[0],targets[1])
#	await UI.AllyRow.sort_children

func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield):
	if targets.size() == 2:
		var slot = UI.getCreatureSlot(targets[0])
		var enemySlot = UI.getCreatureSlot(targets[1])
		
		await UI.swapSlots(slot,enemySlot).finished
	
