class_name Damage extends Object

#damage dealt object
#this could probably be added to just Move but then the DAMAGE_TYPES enum would be
#Move.Damage.DAMAGE_TYPES which is way too much typing

#the amount of damage to deal
var damage:int = 0 

enum DAMAGE_TYPES
{
	PHYSICAL = 0,
	BURN,
	FREEZE,
	SHOCK,
	CORROSIVE,
	PSYCHIC,
	TRUE
}

var type:DAMAGE_TYPES = DAMAGE_TYPES.PHYSICAL;

func _init(damage:int,type:DAMAGE_TYPES):
	self.damage = damage
	self.type = type
