class_name Flamethrower extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	moveName = "Flamethrower"
	pass

func moveAnimationSequence(user,move, targets):
	var sequence = [];
	var unit = SequenceUnit.createAnimationUnit(SpriteLoader.get_sprite("flamethrower"))
	sequence.append(unit)
	return sequence

func move(ally, enemies):
	if len(enemies) > 0: #just to be safe, make sure we are actually targeting something
		Creature.dealDamage(ally,enemies[0],90); #realistically the player should only be targeting one enemy, but even if they target multiple, we only hit the first
	super.move(ally,enemies)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
