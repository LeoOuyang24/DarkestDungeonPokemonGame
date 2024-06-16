class_name SwapPos extends Move



func _init():
	moveName = "Tactic: Swap"
	manualTargets = 1
	targetingCriteria=Move.TARGETING_CRITERIA.ONLY_ALLIES

func moveAnimationSequence(user, move, targets):
	var sequence = []
	
	sequence.push_back(SequenceUnit.createSequenceUnit(func (d,b,u):
		var slot = u.getCreatureSlot(user);
		if targets.size() > 0:
			var enemySlot = u.getCreatureSlot(targets[0])
			#print(slot.Sprite)
			var index = b.getCreatureIndex(user)
			var result = Move.moveTowards(index,targets[0],u,true) 
			if result == SequenceUnit.RETURN_VALS.DONE:
				return SequenceUnit.RETURN_VALS.DONE
			elif result == SequenceUnit.RETURN_VALS.NOT_DONE:
				Move.moveTowards(targets[0],index,u,true)
				return SequenceUnit.RETURN_VALS.NOT_DONE
		return SequenceUnit.RETURN_VALS.DONE
		))
	
	return sequence

func move(user, targets, battlefield):
	battlefield.swapCreature(battlefield.getCreatureIndex(user),targets[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
