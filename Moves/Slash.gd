class_name Slash extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	manualTargets = 0;
	moveName="Slash"
	
	
func moveAnimationSequence(user, move, targets):
	var sequence = [];
	var unit = SequenceUnit.createSequenceUnit(func (d,b,u):
		var slot = u.getCreatureSlot(user)
		var targetIndex = null
		var enemies = b.getEnemies(user.getIsFriendly())
		for i in range(enemies.size()):
			if enemies[i]:
				targetIndex = i
				break
		var val = Move.moveTowards(b.getCreatureIndex(user),targetIndex,u)
		return val
		
		);
	
	sequence.append( unit)
	return sequence;
	
func getPreselectedTargets(allies:Array,enemies:Array):
	var targetsArr = []
	for i in range(enemies.size()):
		if enemies[i]:
			targetsArr.push_back(i)
		if targetsArr.size() >= 2:
			break;
	return targetsArr;

	
func move(user, targets, battlefield):
	var arr = battlefield.getEnemies(user.getIsFriendly()) 
	var count = 0
	for i in arr:
		if i:
			Creature.dealDamage(user,i,30);
			count +=1
		if count >=2:
			break;
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
