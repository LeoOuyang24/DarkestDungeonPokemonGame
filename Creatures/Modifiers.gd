class_name StatModTracker extends Object

#tracks modifiers to a stat

var add:int = 0; #additive multipliers
var mult:float = 1; #multiplicative multipliers

var addSources:Dictionary #maps objects to ints,corresponding to the 
							#sources of various additive changes

var multSources:Dictionary #same as above but for multiplication

#adds/updates a source of additive multiplier
func addAdd(amount:int, obj:Variant) -> void:
	if addSources.has(obj): #update if this source is already accounted for
		add += amount - addSources[obj]
	else:
		add += amount
		
	addSources[obj] = amount


func multMult(amount:float, obj:Variant) -> void:
	if multSources.has(obj):
		mult *= amount/(multSources[obj] if multSources[obj] != 0 else 1) #if old source was 0, divide by 1 instead
	else:
		mult *= amount;
		
	multSources[obj] = amount
	
func removeSource(obj:Variant) -> void:
	if addSources.has(obj):
		addAdd(0,obj) #remove the buff
		addSources.erase(obj)
	
	if multSources.has(obj):
		if multSources[obj] != 0:
			multMult(1.0/multSources[obj],obj)
		else:
			mult = recalcMult() #if multiplier was 0, we'll have to recalculate
		multSources.erase(obj)
#recalculate multiplicative multiplier
#usually done when a multiplier of 0 is removed
func recalcMult() -> float:
	var temp = 1;
	for source in multSources:
		temp *= multSources[source]
		if multSources[source] == 0: #can finish early if we got 0
			break
	return temp
	
#get the value(s) of a source. x value is additive, y is multiplicative.
#if either is nonexistent, the corresponding value is either 0 or 1. 
func getSourceValue(source:Variant) -> Vector2:
	return Vector2(addSources[source] if addSources.has(source) else 0, multSources[source] if multSources.has(source) else 1);
	
#actually get the final value
func getValue(value:int) -> int:
	return mult*(value + add)

func reset() -> void:
	add = 0;
	mult = 1;
