class_name SwapPos extends Move



func _init():
	moveName = "Tactic: Swap"
	setManualTargets(1)
	targetingCriteria=Move.TARGETING_CRITERIA.ONLY_ALLIES

func moveAnimationSequence(user, move, targets):
	var sequence = []
	
	sequence.push_back(SequenceUnit.createSequenceUnit(func (d,b,u):
		var slot = u.getCreatureSlot(user);
		if targets.size() > 0:
			var enemySlot = u.getCreatureSlot(targets[0])
			#print(slot.Sprite)
			if abs(slot.Sprite.global_position.x-enemySlot.global_position.x) >= 0.1:
				slot.Sprite.global_position += 0.1*(enemySlot.global_position - slot.global_position)
				enemySlot.Sprite.global_position += 0.1*(slot.global_position - enemySlot.global_position)
				return SequenceUnit.RETURN_VALS.NOT_DONE
			else:
				slot.Sprite.global_position = slot.global_position
				enemySlot.Sprite.global_position = enemySlot.global_position
				var friendly = b.isCreatureFriendly(user)

				var oldIndex = b.getCreatureIndex(user)
				b.moveCreature(user,b.getCreatureIndex(targets[0]))
				b.moveCreature(targets[0],oldIndex)
				print(user," ", targets[0])
				#print(slot.creature,u.creatureSlots[2].creature)
				#enemySlot.setCreature(user)

		return SequenceUnit.RETURN_VALS.DONE
		))
	
	return sequence

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
