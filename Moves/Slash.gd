class_name Slash extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	manualTargets = 0;
	moveName="Slash"
	
	
#func moveAnimationSequence(user, move, targets):
	#var sequence = [];
	#var unit = SequenceUnit.createSequenceUnit(func (d,b,u):
		#var slot = u.getCreatureSlot(user)
		#var targetIndex = null
		#var enemies = b.getEnemies(user.getIsFriendly())
		#for i in range(enemies.size()):
			#if enemies[i]:
				#targetIndex = i
				#break
		#var val = Move.moveTowards(b.getCreatureIndex(user),targetIndex,u)
		#return val
		#
		#);
	#
	#sequence.append( unit)
	#return sequence;
	
func getPreselectedTargets(user:Creature, battle:Battlefield):
	var enemies = battle.getEnemies(user.getIsFriendly())
	var targetsArr = []
	for i in range(enemies.size()):
		if enemies[i]:
			targetsArr.push_back(battle.relPosToAbs(i,enemies[i].getIsFriendly()))
		if targetsArr.size() >= 2:
			break;
	return targetsArr;

	
func move(user, targets, battlefield):
	#var arr = battlefield.getEnemies(user.getIsFriendly()) 
	#var count = 0
	for i in targets:
		var target = battlefield.getCreature(i)
		if target:
			Creature.dealDamage(user,target,user.getAttack()/2);
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
