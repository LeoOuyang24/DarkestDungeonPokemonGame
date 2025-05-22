class_name Brutalize extends GenericAttack


# Called when the node enters the scene tree for the first time.
func _init():
	super("Brutalize",1,3,"Deal 1x damage to an enemy and inflict Bruised")
	icon = load("res://sprites/icons/moves/fist.png")

func extras(user:Creature,target:Creature,battle:Battlefield) -> void:
	if target:
		battle.events.applyStatus(user,target,Bruised.new(),2)
