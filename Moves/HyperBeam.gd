class_name HyperBeam extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	manualTargets = 0;
	totalTargets = 2
	moveName="Hyper Beam"
	
	
#func moveAnimationSequence(user, move, targets):
	#var sequence = [];
	#var unit = SequenceUnit.createAnimationUnit(SpriteLoader.get_sprite("spritesheets/moves/laser"));
	#
	#sequence.append( unit)
	#return sequence;
	
func getPreselectedTargets(allies:Array,enemies:Array):
	var targetsArr = []
	for i in enemies:
		if i:
			targetsArr.push_back(i)
		if targetsArr.size() >= 2:
			break;
	return targetsArr;

	
func move(user, targets):
	for i in targets:
		Creature.dealDamage(user,i,100);
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
