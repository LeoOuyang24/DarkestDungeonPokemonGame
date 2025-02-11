class_name Entangle extends Move


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _init():
	manualTargets = 0;
	moveName="Entangle"
	icon = load("res://sprites/icons/moves/entangle.png")
	summary="Paralyze two frontmost targets for two turns."
	
func runAnimation(user:Creature, enemies: Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,enemies,UI,self)
	
func getPreselectedTargets(user:Creature, battle:Battlefield):
	return battle.getFrontMostCreatures(2,user.getIsFriendly())

	
func move(user, targets, battlefield):
	#var arr = battlefield.getEnemies(user.getIsFriendly()) 
	#var count = 0
	for i in targets:
		var target = battlefield.getCreature(i)
		if target:
			target.statuses.addStatus(Paralyzed.new(),2);
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
