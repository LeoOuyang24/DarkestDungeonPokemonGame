class_name MoveQueue extends Node



#the actual move units
#Holds a bunch of MoveRecords, representign the info of a move call

#this list is sorted from lowest to highest speed
#so to use it in order, you have to go from end to the beginning
#this is slighly more efficient since popping back is faster than popping first
var data = [];
#map of each creature to the record of what move they are using
var movesSelected = {};

#remove a creature from teh queue
func removeUser(creature:Creature):
	var found = getSpotInQueue(creature)
	if found != -1:
		data.pop_at(found)
		movesSelected.erase(creature)	

func remove(moveInfo:Move.MoveRecord):
	removeUser(moveInfo.user)

#insert a move. returning the index
func insert(moveInfo:Move.MoveRecord) -> int:
	var index = -1
	if !movesSelected.has(moveInfo.user):
		var inserted = false
		for i in range(data.size()):
			#>= creates a "first come first serve" tie breaker.
			#if 2 moves have the same speed, the one that was added first comes first
			if data[i].getSpeed() < moveInfo.user.getSpeed():
				index = i
				data.insert(i,moveInfo.user)
				inserted = true
				break
		#if we never inserted, this is the new fastest move
		if !inserted:
			data.insert(data.size(),moveInfo.user)
			index = data.size()
	movesSelected[moveInfo.user] = moveInfo
	return index
#returns a creature's position (index) in queue, -1 if not in queue or if there's an invalid move
func getSpotInQueue(creature:Creature) -> int:
	if !movesSelected.has(creature):
		return -1
	return data.find(creature)
	
#return if a creature has a valid move selected
func hasMove(creature:Creature) -> bool:
	#print(movesSelected[creature].move)
	return movesSelected.has(creature) && movesSelected[creature].move
	
#returns the number of entries, think of it as how many creatures are in queue
func getUniqueEntries() -> int:
	return movesSelected.size()
	
func top():
	if data.size() > 0:
		return movesSelected[data[0]]
	return null

#clear all contents
func clear():
	data.clear()
	movesSelected.clear()

