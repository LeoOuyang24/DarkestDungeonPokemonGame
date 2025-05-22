class_name BleedingBlades extends GenericAttack

# Called when the node enters the scene tree for the first time.
func _init():
	super("Bleeding Blades",1,3,"Deal 1x damage to a chosen target and inflict 3 stacks of bleed.")
	icon = load("res://sprites/icons/moves/move_bleeding.png")

func extras(user:Creature,target:Creature,battle:Battlefield):
	battle.events.applyStatus(user,target,Bleed.new(),3)
		

	
