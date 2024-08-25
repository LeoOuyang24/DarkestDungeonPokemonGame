class_name GrantSpeed extends Move


const amount:int = 3 #amount of health to restore
var texture = Anime.new()
# Called when the node enters the scene tree for the first time.
func _init():
	super("Give Speed",1,10)
	targetingCriteria = TARGETING_CRITERIA.ONLY_ALLIES
	summary = "Give a creature +5 speed"
	pass # Replace with function body.

func move(user:Creature, targets:Array, battlefield):
	if len(targets) > 0: #just to be safe, make sure we are actually targeting something
		var target = battlefield.getCreature(targets[0])
		print(target)
		target.setStat(Creature.STATS.SPEED,target.getSpeed() + 5)
	pass
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
