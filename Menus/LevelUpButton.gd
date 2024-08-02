extends Button

@onready var Cost = $Cost

var creature:Creature = null

func _ready():
	#disable our button if we run out dna
	self.pressed.connect(levelUp)


func setCreature(creature:Creature) -> void:
	self.creature = creature
	if creature:
		Cost.set_text(str(getLevelUpCost()))
		creature.leveled_up.connect(func():
			Cost.set_text(str(getLevelUpCost()))
			)
			
#feel like this is the easiest way to consolidate when the button is disabled into one function
#rather than spreading it out between two signals
func _process(delta):
	disabled = GameState.getInBattle() or GameState.getDNA() < getLevelUpCost()


#how much dna it takes to level up
func getLevelUpCost() -> int:
	return creature.getLevel() if creature else 0
		
func levelUp():
	if creature:
		GameState.setDNA(GameState.getDNA() - getLevelUpCost())
		creature.levelUp()
		#updateCreature()
	pass

func _get_tooltip ( _at_position:Vector2 ) -> String:
	if GameState.getInBattle():
		return "Can't level up while in combat!"
	if getLevelUpCost() > GameState.getDNA():
		return "You lack DNA!"
	else:
		return "Level up your creature, increasing all stats by 1!"



