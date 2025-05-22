class_name Static extends Move

class StaticEffect extends StatusEffect:
	func _init():
		super("Static",load("res://sprites/statuses/shock.png"),\
		"Whenever this creature attacks this turn, 10 shock is applied to the target")
		
	func onAdd(c:Creature) -> void:
		super(c)
		if GameState.getBattle():
			GameState.getBattle().events.attacked.connect(onAttack)
		
	func onAttack(attacker:Creature,target:Creature,damage:Damage,move:Move):
		if attacker == creature and target and GameState.getBattle():
			GameState.getBattle().events.applyStatus(attacker,target,Shock.new(),2)
			
	func newTurn() -> void:
		setStacks(0)


# Called when the node enters the scene tree for the first time.
func _init():
	super("Static",1,4)
	targetingCriteria = TARGETING_CRITERIA.ONLY_ALLIES
	icon = load("res://sprites/statuses/shock.png")
	summary = "Choose an ally. Every time they deal damage this turn, 10 shock is also applied."
	pass # Replace with function body.


func move(user:Creature, targets:Array, battlefield):
	if targets.size() > 0 and battlefield.getCreature(targets[0]):
		var target:Creature = battlefield.getCreature(targets[0])
		if target:
			battlefield.events.applyStatus(user,target,StaticEffect.new(),1)


	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

	
