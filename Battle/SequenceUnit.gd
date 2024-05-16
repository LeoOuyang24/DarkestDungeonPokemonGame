class_name SequenceUnit extends Object

#SequenceUnit is a single unit of something happening in a battle
#it could be the text showing an attack being used, the subsequent animation of the attack, etc.

const standardUnitTime = 1000; #number of ms to run by default

#different values that can be returned by a SequenceUnit
enum RETURN_VALS{
	NOT_DONE, #keep running this unit
	DONE, #done with this unit, move on
	TERMINATE #stop running this unit AND the rest of the sequence
	
}

#a callable function that represents what this unit does, should take in delta, and a battlestate and battleUI and returns whether this unit is done or not
#(delta, battleState, battleUI) -> RETURN_VALS
var callable  = null; 
var timeStart = -1; #ms we started at
	
func run(delta, battleState, UI):
	if self.timeStart == -1:
		self.timeStart = Time.get_ticks_msec()
	if callable:
		return callable.call(delta,battleState, UI)
	return RETURN_VALS.DONE;

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
	unit.callable = func (delta, battleState, battleUI):
		if battleUI:
			battleUI.setBattleText(text)
		if unit.timePassed():
			return RETURN_VALS.DONE;
		return RETURN_VALS.NOT_DONE;
	return unit;
	
static func createAnimationUnit(sprite:SpriteFrames):
	var unit = SequenceUnit.new();
	
	unit.callable = func (delta, battleState, battleUI):
		battleUI.setBattleSprite(sprite)
		if unit.timePassed():
			battleUI.stopBattleSprite();
			return RETURN_VALS.DONE;
		return RETURN_VALS.NOT_DONE;
		
	return unit;

static func createDeathSequence(creature:Creature):
	var sequence = []
	sequence.push_back(createTextUnit(creature.getName() + " has been exterminated!"))
	sequence.push_back(createSequenceUnit(func(d,b,u):
		b.removeCreature(creature);
		u.removeCreature(creature);
		return RETURN_VALS.DONE
		))
	return sequence;



#constructs a whole Sequence (list of SequenceUnits) that describe a move
static func createMoveSequence(user,move, targets):
	var sequence = []
	sequence.push_back( createTextUnit(user.getName() + " used " + move.getMoveName() + "!")); #say whos doing the  move
	sequence.push_back(createSequenceUnit(func (d,b,u) : #do the move
		user.useMove(move,targets)
		return RETURN_VALS.DONE
		)); 
	
	return sequence;
	
	
	
