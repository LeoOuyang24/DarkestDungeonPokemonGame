class_name SequenceUnit extends DFAUnit

#SequenceUnit is a single node in a DFA
#it could be the text showing an attack being used, the subsequent animation of the attack, etc.

#Basically the main difference between SequenceUnit and DFA is that it is explicitly supposed to run
#on BattleManagers and can either run on BattleManagers or a Battelfield and a BattleUI
#this is a relic of older code design, that I now need to awkwardly write over to make everythign work

#sometimes it's more convenient to directly interface with the BattleManager rather than the battleState and UI
#set this true and the callable function will instead take in delta and BattleManager
#(delta,BattleManager) -> RETURN_VALS
var usesManager = false;

func run(delta, battleManager):
	if self.timeStart == -1:
		self.timeStart = Time.get_ticks_msec()
	if callable:
		if usesManager:
			return callable.call(delta, battleManager)
		return callable.call(delta,battleManager.BattleSim, battleManager.UI)
	return RETURN_VALS.DONE;

static func createSequenceUnit(callable:Callable, usesManager:bool = false):
	var unit = SequenceUnit.new();
	unit.callable = callable;
	unit.usesManager = usesManager;
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
	
	
	
