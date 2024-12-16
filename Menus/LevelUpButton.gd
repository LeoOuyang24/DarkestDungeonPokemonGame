extends CostButton

func setCreature(creature:Creature) -> void:
	if creature:
		comp.cost = (getLevelUpCost(creature))
		creature.level.leveled_up.connect(func():
			comp.cost = (getLevelUpCost(creature))
			)

#how much dna it takes to level up
func getLevelUpCost(creature:Creature) -> int:
	return creature.getLevel() if creature else 0

func _get_tooltip ( _at_position:Vector2 ) -> String:
	if GameState.getInBattle():
		return "Can't level up while in combat!"
	if disabled:
		return "You lack DNA!"
	else:
		return "Level up your creature, increasing all stats by 1!"



