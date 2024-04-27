class_name CreatureSlot extends Button

#represents the visual representation of a creature on the battlefield

@onready var Sprite = $Sprite
@onready var HealthBar = $HealthBar;

#a reference to the creature we are referring to
var creature:Creature = null

func setCreature(creature:Creature):
	self.creature = creature;
	HealthBar.set_value(creature.getHealth())
	
func getCreature():
	return self.creature
# Called when the node enters the scene tree for the first time.
func _ready():
	#icon = load("res://sprites/dialga.png")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !creature:
		set_visible(false)
	else:
		#refactor maybe: instead of doing this every frame, maybe do it when the health changes?
		HealthBar.set_value(creature.getHealth())

