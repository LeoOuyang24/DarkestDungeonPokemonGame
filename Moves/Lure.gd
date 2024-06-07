class_name Lure extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	moveName = "Lure"

func moveAnimationSequence(user, move, targets):
	return Move.createBoostStatsSequence([user], true);
	
func postMoveSequence(user, move, targets):
	return [SequenceUnit.createTextUnit(user.getName() + "\'s Attack rose 2 stages!")]

func getPreselectedTargets(allies:Array,enemies:Array):	
	for i in range(enemies.size()):
		
	return preselected;	

func doMoveSequence(user, move, targets):
	var unit = SequenceUnit.new()
	unit.vars.furthest  = null
	unit.callable = func (d,b,u) : #do the move
		for i in range(Battlefield.maxEnemies):
			
	return unit
			
		
		return SequenceUnit.RETURN_VALS.DONE
	)]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
