class_name DFAUnit extends Object

#A node in a DFA, used to represent the state of somethingdedicated
#Originally SequenceUnit was used to keep track of battle events, but later I found that DFAs are useful
#for everything. This is a more generic version of SequenceUnit

const standardUnitTime = 1000; #number of ms to run by default

#different values that can be returned by a SequenceUnit
enum RETURN_VALS{
	NOT_DONE, #keep running this unit
	DONE, #done with this unit, move on
	TERMINATE #stop running this unit AND the rest of the sequence
	
}

var callable  = null; 
var timeStart = -1; #ms we started at

#pass in deltaTime and an object (can be anything). The DFAUnit will run a function on it and return what 
#node to transition to. NOT_DONE means stay on this unit, DONE means move onto the next. TERMINATE means to stop running
#the entire sequence

func _init(callable:Callable = func():
	pass
	):
	self.callable = callable

func run(delta, obj):
	if self.timeStart == -1:
		self.timeStart = Time.get_ticks_msec()
	if callable:
		return self.callable.call(delta,Time.get_ticks_msec() - self.timeStart,obj) #pass in how long we've been on this unit as a 2nd parameter
	return RETURN_VALS.DONE;

#if we have run for "duration" ms, return true
func timePassed(duration:int = standardUnitTime) -> bool:
	return Time.get_ticks_msec() - self.timeStart >= standardUnitTime
	 

