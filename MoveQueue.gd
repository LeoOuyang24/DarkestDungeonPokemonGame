class_name MoveQueue extends Object


#the underlying data storage
var data:Array = [];

#compares 2 creatures to see which one is slower
#speed ties are broken by whoever was added first
func _compare(c1:Creature, c2:Creature):
	return c1.getSpeed() < c2.getSpeed();

#given a priority, finds the index the creature belongs in
func find(creature:Creature):
	if data.size() > 0:
		return data.bsearch_custom(creature, self._compare)
	return 0 #binary search crashes if array is empty

func insert(creature:Creature):
	var index = find(creature);
	#omega inefficient but Godot doesn't have binary trees ARRGHGHGGHGHG 		
	data.insert(index,creature)

#clear all contents
func clear():
	data.clear()

#to update creatures' positions, remove from the queue and then insert
