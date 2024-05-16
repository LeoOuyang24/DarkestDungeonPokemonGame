class_name NastyPlot extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	moveName = "Nasty Plot"

func moveAnimationSequence(user, move, targets):
	return Move.createBoostStatsSequence(targets, true);
	
func postMoveSequence(user, move, targets):
	return [SequenceUnit.createTextUnit(user.getName() + "\'s Attack rose 2 stages!")]
	
func move(user,targets):
	user.attackStages += 2;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
