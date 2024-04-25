class_name NastyPlot extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	moveName = "Nasty Plot"

func moveAnimationSequence(user, move, targets):
	#This animation causes the user to move in a circle
	var sequence = [];
	var unit = SequenceUnit.new();
	var pos = user.position;
	const unitTime = 1000; #time of this unit
	var radius = 10
	var center = pos + Vector2(0,radius);
	unit.callable = func (delta, battleState):
		var timeSince = Time.get_ticks_msec() - unit.timeStart;
		var angle = float(timeSince)/unitTime*2*PI - PI/2 #offset by 90 Deg so when timeSince=0, we start at our starting position
		user.position = center + radius*Vector2(cos(angle),sin(angle))
		if timeSince>= unitTime:
			user.position = pos;
			return true;
		return false;
		
	sequence.append( unit)
	return sequence;
	
func postMoveSequence(user, move, targets):
	return [SequenceUnit.createTextUnit(user.getName() + "\'s Attack rose 2 stages!")]
	
func move(user,targets):
	user.attackStages += 2;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
