class_name GrantAttack extends Move


const amount:int = 3 #amount of health to restore
# Called when the node enters the scene tree for the first time.
func _init():
	super("Give Attack",1,10)
	targetingCriteria = TARGETING_CRITERIA.ONLY_ALLIES
	icon = load("res://sprites/icons/moves/upicon.png")
	summary = "Increase ally attack by 1.5x."
	pass # Replace with function body.

func move(user:Creature, targets:Array, battlefield):
	if len(targets) > 0: #just to be safe, make sure we are actually targeting something
		var target = battlefield.getCreature(targets[0])
		var attack:Stat = target.stats.getStatObj(CreatureStats.STATS.ATTACK)
		attack.addStat(.5*attack.getCurStat())
	pass
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
