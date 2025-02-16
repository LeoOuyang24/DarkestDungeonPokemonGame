class_name MoveQueue extends Node

#queue of moves, which is represented by MoveRecords.
#higher speed creatures move first.
#tie breaks are broken based on first come first serve, so if A has the same speed as B but 
#A was added first, B will go after A.
#Dynamic speed ties (ties that happen mid-combat) are resolved based where A and B were relative to each other
#before the tie.
#So for example, let's say A is faster than B
#Then, A is debuffed to be the same speed as B. Because A was faster than B before, it still goes first.
#similarly, if B is buffed to be the same speed as A, it still goes after A since it was slower previously.

signal add_move(record:Move.MoveRecord)

#the actual move units
#Holds a bunch of MoveRecords, representign the info of a move call
#array of records sorted from highest to lowest speed
var data:Array[Move.MoveRecord] = [];

#the index of the current record that is running
#-1 if the queue hasn't been run yet (no record has been run)
#all records at index <= head have already been run or are currently being run and therefore
#can not have their positions changed by speed changes
var head:int = -1; 

#remove a creature from the queue
#does nothing if creature is not in queue
func remove(creature:Creature) -> void:
	var found = find(creature)
	if found != -1:
		data.pop_at(found)		

#insert a move. returning the index
#if the user already exists, its record is updated and its spot is still attempted to be updated (may not do anything if it hasn't changed speed)
#if the user does not already exist, the record is added to the end and then moved to the right spot
#if the record is null or user is null, -1 is returned
func insert(moveInfo:Move.MoveRecord) -> int:
	if moveInfo == null or moveInfo.user == null:
		return -1
	var index = find(moveInfo.user)
	if find(moveInfo.user) == -1:
		#it's important that we push a new record to the back to maintain FIFO. Pushing it to the end means
		#it loses every tie break, going after every creature with the same speed.
		#technically there is a bit of redundancy here, since in updateSpot, we just pop it back out immediately
		#but it's not a bit problem since popping from the end of an array is O(1) anyway.
		data.push_back(moveInfo)
	else:
		data[index] = moveInfo

	add_move.emit(moveInfo)
	return updateSpot(moveInfo.user)
	
#update a creature's position in queue.
#if it is not in the queue or if its position can not change because it has already been processed, 
#nothing happens and -1 is returned.
#otherwise the creature is moved to a new position (ties are placed after preexisting records) 
#and the new position is returned.
func updateSpot(creature:Creature) -> int:
	if creature:
		var index := find(creature)
		if index != -1 and index > head: #make sure record hasn't been processed and is in queue
			var curSpeed := creature.stats.getCurStat(CreatureStats.STATS.SPEED)

			var old:Move.MoveRecord = data.pop_at(index)
			
			#begin a binary search
			#low and high are the lowest and highest possible indices of elements in the array
			#Inevitably, low and high will be equal (unless size is 0, in which case it doesn't matter).
			#When this is the case, data[low] is the creature with the closest speed to our updatee.
			#On the next iteration, either "low" will +1 and increase past "high", because the closest
			#creature in speed is faster than the creature we are inserting, or
			#high will -1 and decrease past "low", in which case the closest creature in speed is slower
			#"high" is always the 2nd highest index you can insert at, because that way, you can always insert at 
			#"low" + 1, which at most is the size of the array, and the last index you can insert at.
			#"low" is always the lowest index you can insert at, ensuring the lowest it can go is 0, which is the
			#lowest index we can insert at
			var high := data.size()-1
			var low := head+1
			
			while low <= high:
				var mid = (low + high)/2
				if curSpeed > data[mid].user.stats.getCurStat(CreatureStats.STATS.SPEED):
					high = mid - 1
				elif curSpeed < data[mid].user.stats.getCurStat(CreatureStats.STATS.SPEED):
					low = mid + 1
				else: #if its a tie, we have to account for relative positions before the update process
					#if we were faster than this creature, we should remain faster even when tied.
					#note that if index == mid, that means that before the pop, index < mid since everything slid down
					if index <= mid:
						high = mid - 1
					#if we were slower, than we remain slower
					else:
						low = mid + 1
			data.insert(low,old)
			return low
	return -1
	
#returns a creature's position (index) in queue, -1 if not in queue
func find(creature:Creature) -> int:
	var i:int = 0
	for record:Move.MoveRecord in data:
		if record.user == creature:
			return i
		i += 1
	return -1
	
#return if a creature has a valid move selected
func hasMove(creature:Creature) -> bool:
	var index := find(creature) 
	return index != -1 and data[index].move
	
func getMove(creature:Creature) -> Move:
	var index := find(creature) 
	return data[index].move if index != -1 else null
	
#returns the number of entries, think of it as how many creatures are in queue
func size() -> int:
	return data.size()
	
#move onto the next record.
func increment() -> void:
	head += 1
	
#get front-most record
func top() -> Move.MoveRecord:
	if head >= data.size() or head < 0:
		return null
	return data[head]

#gets the next record to run, and "pops" it. It doesn't actually delete it, but by incrementing "head"
#we note that this record is the new one running and thus can't have its position in the queue changed.
func pop() -> Move.MoveRecord:
	head += 1
	return top()
	
#typically used every new turn to prepare queue for new turn
#you could probably find a way to do this without having to delete every record, but I think this is
#easier.
func reset():
	head = -1
	data.clear()
		
#clear all contents
func clear():
	data.clear()
