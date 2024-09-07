class_name CreateHorrorButton extends AnimatedButton

var creature:Creature = null

func setCreature(creature:Creature) -> void:
	self.creature = creature
	setSprite(creature.getSprite())
	updateDisabled()


#update disabled based on whether or not the creature is already in the party
func updateDisabled():
	disabled = GameState.PlayerState.getTeam().reduce(func (accum:bool, creature2:Creature):
			return accum || creature2.getName() == creature.getName()
			,false)	
	modulate = Color(0.2,0.2,0.2,1) if disabled else Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready():
	ignore_texture_size = true
	setSize(Vector2(100,100))
	
	

