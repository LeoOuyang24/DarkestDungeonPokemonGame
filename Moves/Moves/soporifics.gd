class_name Soporifics extends Move


	
func _init():
	manualTargets = 1;
	moveName="Soporifics"
	icon = load("res://sprites/icons/moves/sleep.png")
	summary="Put a creature to sleep for 2 turns"
	
func runAnimation(user:Creature, enemies: Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,enemies,UI,self)

	
func move(user, targets, battlefield):
	if targets.size() > 0:
		battlefield.events.applyStatus(user,battlefield.getCreature(targets[0]),Sleep.new(),2)
