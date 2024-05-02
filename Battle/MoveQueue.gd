class_name MoveQueue extends Node



#the actual move units
#Holds a bunch of MoveRecords, representign the info of a move call

#this list is sorted from lowest to highest speed
#so to use it in order, you have to go from end to the beginning
#this is slighly more efficient since popping back is faster than popping first
var data = [];

#insert a move. 
func insert(moveInfo:MoveRecord):
	#omega inefficient but Godot doesn't have binary trees ARRGHGHGGHGHG 		
	var found = false;
	for i in range(data.size()):
		#>= creates a "first come first serve" tie breaker.
		#if 2 moves have the same speed, the one that was added first comes first
		if data[i].user.getSpeed() >=moveInfo.user.getSpeed():
			data.insert(i,moveInfo)
			found = true;
			break;
	#if we never inserted, this is the new fastest move
	if !found:
		data.insert(data.size(),moveInfo)
		

#call the next callable
func pop():
	var returnVal = null;
	if data.size() > 0:
		#only add the move if the creature is still alive
		if data[data.size() - 1].user.isAlive():
			returnVal = data[data.size() - 1].getSequence();
		data.pop_back();
	return returnVal;

	

#clear all contents
func clear():
	data.clear()

