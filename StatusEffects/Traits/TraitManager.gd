class_name TraitManager extends StatusManager


#unlike StatusManager, Traits don't stack, so make sure we dont have duplicates
func addStatus(status:StatusEffect,stacks:int = 1) -> void:
	if !statuses.has(status.name):
		#if this status effect is already in our creature, just add stacks
		super.addStatus(status,1);
		
func getAdjective() -> String:
	var accum := ""
	for status:String in statuses:
		if statuses[status].getAdj().length() > 0:
			accum += statuses[status].getAdj() + " " 
	return accum
	
func inBattle(battlefield:Battlefield) -> void:
	for i:String in statuses:
		statuses[i].inBattle(battlefield)
	pass
	
func onAddUI(slot:CreatureSlot) -> void:
	for i:String in statuses:
		statuses[i].onAddUI(slot)
		
func onRemoveUI(slot:CreatureSlot) -> void:
	for i:String in statuses:
		statuses[i].onRemoveUI(slot)
