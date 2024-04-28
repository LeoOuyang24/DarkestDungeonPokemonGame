class_name MoveQueue extends Node



#the actual move units
#Holds a bunch of "Pairs", the first element is the user of the move
# the 2nd element is a Callable that assembles the move sequence when called with no parameters
#the pairs are actually arrays with 2 elements (I HATE GODOT)
#this list is sorted from lowest to highest speed
#so to use it in order, you have to go from end to the beginning
#this is slighly more efficient since popping back is faster than popping first
var data = [];

#insert a move. 
func insert(creature:Creature, callable:Callable):
	#var index = find(creature);
	#omega inefficient but Godot doesn't have binary trees ARRGHGHGGHGHG 		

	var found = false;
	for i in range(data.size()):
		#>= creates a "first come first serve" tie breaker.
		#if 2 moves have the same speed, the one that was added first comes first
		if data[i][0].getSpeed() >= creature.getSpeed():
			data.insert(i,[creature,callable])
			found = true;
			break;
	#if we never inserted, this is the new fastest move
	if !found:
		data.insert(data.size(),[creature,callable])
		

#call the next callable
func pop():
	if data.size() > 0:
		#only add the move if the creature is still alive
		if data[data.size() - 1][0].isAlive():
			data[data.size() - 1][1].call();
		data.pop_back();
	

#clear all contents
func clear():
	data.clear()

