class_name Splash extends Move




# Called when the node enters the scene tree for the first time.
func _init():
	moveName = "Splash"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func move(user,enemies):
	pass;
	
func postMoveSequence(user,move, targets):
	var sequence = [];
	sequence.append(SequenceUnit.createTextUnit("It did nothing!"))
	return sequence;
