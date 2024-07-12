class_name MoveQueue extends Node



#the actual move units
#Holds a bunch of MoveRecords, representign the info of a move call

#this list is sorted from lowest to highest speed
#so to use it in order, you have to go from end to the beginning
#this is slighly more efficient since popping back is faster than popping first
var data = [];

func remove(moveInfo:Move.MoveRecord):
	data.erase(moveInfo);

#insert a move. returning the index
func insert(moveInfo:Move.MoveRecord) -> int:
	#omega inefficient but Godot doesn't have binary trees ARRGHGHGGHGHG 		
	for i in range(data.size()):
		#>= creates a "first come first serve" tie breaker.
		#if 2 moves have the same speed, the one that was added first comes first
		if data[i].user.getSpeed() >=moveInfo.user.getSpeed():
			data.insert(i,moveInfo)
			return i;
	#if we never inserted, this is the new fastest move
	data.insert(data.size(),moveInfo)
	return data.size() - 1;
		
#returns an array of creatures in the queue, in the order they'd move
#this is sorted from first to move to last to move
func getCreatures():
	var arr = [];
	for i in range(data.size(),0,-1):
		arr.push_back(data[i-1].user);
	return arr;
	
	
func top():
	if data.size() > 0:
		return data[-1]
	return null
	
#return the next sequence
func topSequence():
	var returnVal = null;
	if data.size() > 0:
		returnVal = data[data.size() - 1];
	return returnVal;
	
func pop():
	if data.size() > 0:
		data.pop_back()


#clear all contents
func clear():
	data.clear()

