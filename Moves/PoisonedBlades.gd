class_name PoisonedBlades extends Move

# Called when the node enters the scene tree for the first time.
func _init():
	super("Envenom",1,5)
	summary = "Inflict 1 stack of Poison."
	pass # Replace with function body.


func move(user:Creature, enemies:Array, battlefield):
	if len(enemies) > 0: 
		var target = battlefield.getCreature(enemies[0]);
		target.statuses.addStatus(Poison.new(),1)
		

	
