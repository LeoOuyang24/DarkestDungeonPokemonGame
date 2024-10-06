class_name MoveQueue extends Node



#the actual move units
#Holds a bunch of MoveRecords, representign the info of a move call

#this list is sorted from lowest to highest speed
#so to use it in order, you have to go from end to the beginning
#this is slighly more efficient since popping back is faster than popping first
var data = [];
#map of each creature to the record of what move they are using
var movesSelected = {};

var index:int = 0; #position we are in the queue

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
	addMove(moveInfo.user,moveInfo)
	return updateSpot(moveInfo.user)
	
#change what move creature is going to use
func addMove(creature:Creature,record:Move.MoveRecord) -> void:
	movesSelected[creature] = record
	
#if creature is in movesSelected, update its position and return its position
#-1 if creature is not in movesSelected
func updateSpot(creature:Creature) -> int:
	var index = -1
	if movesSelected.has(creature):
		var inserted = false
		data.erase(creature);
		for i in range(data.size()):
			#>= creates a "first come first serve" tie breaker.
			#if 2 moves have the same speed, the one that was added first comes first
			if data[i].stats.getCurStat(CreatureStats.STATS.SPEED) < creature.stats.getCurStat(CreatureStats.STATS.SPEED):
				index = i
				data.insert(i,creature)
				inserted = true
				break
		#if we never inserted, this is the new fastest move
		if !inserted:
			index = data.size()	
			data.insert(data.size(),creature)
	return index
	
#returns a creature's position (index) in queue, -1 if not in queue
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
	
func top() -> Move.MoveRecord:
	if data.size() > index:
		return movesSelected[data[index]]
	return null

#increase index
func increment():
	index += 1
	
#clear all moves, but don't remove teh creatures
func reset():
	index = 0;
	for creature in movesSelected:
		movesSelected[creature].move = null
		
#clear all contents
func clear():
	index = 0;
	data.clear()
	movesSelected.clear()

