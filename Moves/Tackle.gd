class_name Tackle extends Move

# Called when the node enters the scene tree for the first time.
func _init():
	moveName = "Tackle"
	pass # Replace with function body.

func move(ally, enemies):
	if len(enemies) > 0: #just to be safe, make sure we are actually targeting something
		Creature.dealDamage(ally,enemies[0],40); #realistically the player should only be targeting one enemy, but even if they target multiple, we only hit the first
	super.move(ally,enemies)
	pass

func moveAnimationSequence(user, move, targets):
	var sequence = [];
	var unit = SequenceUnit.new();
	var pos = user.position;
	
	unit.callable = func (delta, battleState):
		user.position += delta*Vector2(1000,0);
		if unit.timePassed():
			user.position = pos;
			return true;
		return false;
		
	sequence.append( unit)
	return sequence;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
