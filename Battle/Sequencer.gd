class_name Sequencer extends Object

#handles a queue of sequences
#a sequence is an array of DEFAUnits
#basically we are holding arrays of DFAUnits

#represents a queue data structure (First in, first out) for our sequences
#this is done by always inserting new elements in the beginning, and then calling
#pop_back. This is slighly more effcient than doing the opposite, which is always
#inserting at the back and calling pop_front. Inserting into the beginning has O(n)
#as is pop_front. So comparing pop_back vs insert at the back, pop_back is always constant
#insert at the back, on the other hand, may cause our array to be recopied if we exceed capacity
var sequences:Array = []

#represents the index of the current unit in the current sequence we are running
var curUnit:int = 0

func insert(sequence:Array):
	#always insert out sequences at the beginning
	sequences.insert(0, sequence)
	
func done():
	return sequences.size() == 0	

func run(delta, obj):
	if sequences.size() > 0:
			#get the result, or default to DONE if there are no sequence Units
			var result = sequences[-1][curUnit].run(delta,obj) if sequences[-1].size() > 0 else SequenceUnit.RETURN_VALS.DONE
			if result == SequenceUnit.RETURN_VALS.DONE: #if we are done with this unit ...
				if curUnit >= sequences[-1].size() - 1:
					#done with this sequence, set up for the next one
					sequences.pop_back();
					curUnit = 0;
				else:
					#advance to the next unit
					curUnit += 1;
			elif result == SequenceUnit.RETURN_VALS.TERMINATE:
				sequences.pop_back();
				curUnit = 0;
				

func runAsync(delta, obj:BattleManager):
	if sequences.size() > 0:
		#get the result, or default to DONE if there are no sequence Units
		var result = sequences[-1][curUnit].run(delta,obj) if sequences[-1].size() > 0 else SequenceUnit.RETURN_VALS.DONE
		if result == SequenceUnit.RETURN_VALS.DONE: #if we are done with this unit ...
			if curUnit >= sequences[-1].size() - 1:
				#done with this sequence, set up for the next one
				sequences.pop_back();
				curUnit = 0;
			else:
				#advance to the next unit
				curUnit += 1;
		elif result == SequenceUnit.RETURN_VALS.TERMINATE:
			sequences.pop_back();
			curUnit = 0;

