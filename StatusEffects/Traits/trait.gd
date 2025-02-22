class_name Trait extends StatusEffect



#traits are never debuffs
func getIsDebuff() -> bool:
	return true;
	
#return an adjective to add to the creature name
func getAdj() -> String:
	return name;

#any setup that needs to be done when entering the battlefield
func inBattle(battlefield:Battlefield) -> void:
	pass
	
func newTurn() -> void:
	pass
	
