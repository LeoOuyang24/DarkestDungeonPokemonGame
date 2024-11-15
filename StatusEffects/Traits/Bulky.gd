class_name Bulky extends Trait


# Called when the node enters the scene tree for the first time.
func _init():
	name = "Bulky"
		

func inBattle(battlefield:Battlefield) -> void:
	battlefield.battle_ended.connect(trigger)
	
func trigger() -> void:
	creature.stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(5,true,self)
