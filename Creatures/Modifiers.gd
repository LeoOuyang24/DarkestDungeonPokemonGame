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
		var value = multSources[obj]
		multSources.erase(obj)
		if value != 0:
			multMult(1.0/value,obj)
		else:
			mult = recalcMult() #if multiplier was 0, we'll have to recalculate

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
#lower = true if we want to include mods that lower our stat
#upper = true if we want to include mods that raise our stat
func getValue(value:int, lower:bool =true, upper:bool=true) -> float:
	if lower and upper: #what will usually happen, we want all modifiers
		return mult*(value + add)
	elif !lower and !upper: #if we want no modifiers, just return the value
		return value 
	else: #otherwise, we'll have to do some calculations
		var addBoost := 0
		var multBoost := 1
		#calculate additive boosts
		for i in addSources:
			if lower and addSources[i] < 0:
				addBoost += addSources[i]
			elif upper and addSources[i] > 0:
				addBoost += addSources[i]
		
		#calculate multiplicative boosts
		for i in multSources:
			if lower and multSources[i] < 1:
				multBoost *= multSources[i];
				if multSources[i] == 0:
					break
			elif upper and multSources[i] > 1:
				multBoost *= multSources[i];
				
		return multBoost*(value + addBoost)

func reset() -> void:
	add = 0;
	mult = 1;
