class_name Backfire extends GenericAttack


# Called when the node enters the scene tree for the first time.
func _init():
	super("Backfire",0,2,"Deal 1.5x damage to the frontmost target and inflict 10 burn to the rearmost ally.")
	icon = load("res://sprites/statuses/burn.png")
	pass # Replace with function body.

func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(1,user.getIsFriendly())


func move(user:Creature, targets:Array, battlefield):
	super(user,targets,battlefield)
	
	var rear = battlefield.getFrontMostCreatures(-1,!user.getIsFriendly(),false)
	if rear.size() > 0:
		battlefield.events.applyStatus(user,rear[0],Burn.new(),10)

	
