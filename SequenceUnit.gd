class_name SequenceUnit extends Object

#SequenceUnit is a single unit of something happening in a battle
#it could be the text showing an attack being used, the subsequent animation of the attack, etc.

const standardUnitTime = 1000; #number of ms to run by default

#a callable function that represents what this unit does, should take in delta, and an object with the start_battle.gd script and returns whether this unit is done or not
#(delta, battleState) -> bool
var callable  = null; 
var timeStart = -1; #ms we started at
	
func run(delta, battleState):
	if self.timeStart == -1:
		self.timeStart = Time.get_ticks_msec()
	if callable:
		return callable.call(delta,battleState)
	return true;

#if we have run for "duration" ms, return true
func timePassed(duration:int = standardUnitTime) -> bool:
	return Time.get_ticks_msec() - self.timeStart >= standardUnitTime
	 

#factory function
static func createSequenceUnit(callable:Callable):
	var unit = SequenceUnit.new();
	unit.callable = callable;
	return unit;

#constructs a SequenceUnit that displays some text in the battlelog
static func createTextUnit(text:String):
	var unit = SequenceUnit.new();
	unit.callable = func (delta, battleState):
		if battleState:
			battleState.setBattleText(text)
		if unit.timePassed():
			return true;
		return false;
	return unit;
	
static func createAnimationUnit(sprite:SpriteFrames):
	var unit = SequenceUnit.new();
	
	unit.callable = func (delta, battleState):
		if battleState:
			battleState.setBattleSprite(sprite);
			

		if unit.timePassed():
			if battleState:
				battleState.setBattleSprite(null);
			return true;
		return false;
		
	return unit;

#constructs a whole Sequence (list of SequenceUnits) that describe a move
static func createMoveSequence(user,move, targets):
	var sequence = []
	sequence.push_back( createTextUnit(user.getName() + " used " + move.getMoveName() + "!")); #say whos doing the  move
	sequence.push_back(createSequenceUnit(func (d,b) : #do the move
		user.useMove(move,targets)
		return true
		)); 
	sequence.push_back(createSequenceUnit(func(d,b):
		b.advanceState();
		return true;
		))
	
	return sequence;
	
	
	
