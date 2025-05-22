class_name Maul extends GenericAttack


# Called when the node enters the scene tree for the first time.
func _init():
	super("Maul",1,2,"Deal 1.8x damage, but user can not attack next turn")
	icon = load("res://sprites/icons/moves/fist.png")
	pass # Replace with function body.

func getMult():
	return 1.8
	

func move(user:Creature, targets:Array, battlefield):
	super(user,targets,battlefield)
	if user:
		user.statuses.addStatus(Dazed.new(),2)

	
