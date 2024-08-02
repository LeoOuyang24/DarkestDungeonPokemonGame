class_name Mend extends Move


const amount:int = 3 #amount of health to restore
var texture = Anime.new()
# Called when the node enters the scene tree for the first time.
func _init():
	super("Mend",1,10)
	targetingCriteria = TARGETING_CRITERIA.ONLY_ALLIES
	summary = "Restore " + str(amount) + " health to an ally."
	pass # Replace with function body.

func move(user:Creature, enemies:Array, battlefield):
	if len(enemies) > 0: #just to be safe, make sure we are actually targeting something
		
		battlefield.getCreature(enemies[0]).addHealth(amount)

	pass
	
func runAnimation(user:Creature, targets:Array, UI:BattleUI,battlefield:Battlefield) -> void:
	await MoveAnimations.genericAttackAnimation(user,targets,UI,self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
