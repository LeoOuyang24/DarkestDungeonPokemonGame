class_name Incinerate extends Move


# Called when the node enters the scene tree for the first time.
func _init():
	super("Incinerate",1,4)
	targetingCriteria = TARGETING_CRITERIA.ONLY_ENEMIES
	icon = load("res://sprites/statuses/burn.png")
	summary = "Double the amount of Burn on a creature"
	pass # Replace with function body.


func move(user:Creature, targets:Array, battlefield):
	if targets.size() > 0 and battlefield.getCreature(targets[0]):
		var target:Creature = battlefield.getCreature(targets[0])
		var burn:StatusEffect = target.statuses.getStatus("Burn")
		if burn:
			battlefield.events.applyStatus(user,target,Burn.new(),burn.getStacks())


	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

	
