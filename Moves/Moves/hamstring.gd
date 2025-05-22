class_name Hamstring extends GenericAttack

# Called when the node enters the scene tree for the first time.
func _init():
	super("Hamstring",1,1,"Deal .75x damage to a chosen target and inflict 2 turns of paralysis")
	icon = load("res://sprites/statuses/paralyzed.png")
	pass # Replace with function body.

func getMult():
	return .75

func extras(user:Creature,target:Creature,battle:Battlefield) -> void:
	if target and battle:
		battle.events.applyStatus(user,target,Paralyzed.new(),2)
		

	
