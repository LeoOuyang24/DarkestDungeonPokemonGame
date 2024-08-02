class_name Scan extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	manualTargets = 0;
	moveName="Scan"
	summary="Add a random enemy's DNA to your database. Creature can be added to your team later."
	
func getPreselectedTargets(user:Creature, battle:Battlefield):
	var enemies = battle.getEnemies(user.getIsFriendly())
	var targetsArr = []
	for i in range(enemies.size()):
		if enemies[i]:
			targetsArr.push_back(i)
	return [battle.relPosToAbs(targetsArr[randi()%targetsArr.size()],!user.getIsFriendly())];

func moveAnimationSequence(user, move, targets):
	return [SequenceUnit.createSequenceUnit(func(d,b,u):
		if targets.size() > 0:
			var slot = u.getCreatureSlot(targets[0])
			var tween = slot.getTween()
			if !tween.is_running():
				tween.tween_property(slot.Sprite,"modulate",Color.MAGENTA,1)
				tween.tween_property(slot.Sprite,"modulate",Color.WHITE,1)
			#await tween.finished
			return SequenceUnit.RETURN_VALS.DONE if !tween.is_valid() else SequenceUnit.RETURN_VALS.NOT_DONE
		return SequenceUnit.RETURN_VALS.DONE 
		)]

func runAnimation(user:Creature, targets:Array, u:BattleUI,battlefield:Battlefield) -> void:
	var slot = u.getCreatureSlot(targets[0])
	var tween = slot.getTween()
	tween.tween_property(slot,"modulate",Color.MAGENTA,0.5)
	tween.tween_property(slot,"modulate",Color.WHITE,0.5)
	await tween.finished

func move(user:Creature, targets:Array,battlefield):
	if targets.size() > 0:
		GameState.PlayerState.addScan(battlefield.getCreature(targets[0]).getName())	
		
func getPostMessage(user:Creature, targets:Array) -> String:
	return "SCANNED!"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
