class_name HyperBeam extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	targets = 0;
	moveName="Hyper Beam"
	
	
#func moveAnimationSequence(user, move, targets):
	#var sequence = [];
	#var unit = SequenceUnit.createAnimationUnit(SpriteLoader.get_sprite("spritesheets/moves/laser"));
	#
	#sequence.append( unit)
	#return sequence;
	
func getPreselectedTargets():
	return [[],[0,1]];
	
func move(user, targets):
	for i in targets:
		Creature.dealDamage(user,i,100);
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
