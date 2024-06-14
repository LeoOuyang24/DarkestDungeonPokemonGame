class_name CreatureSlot extends Button

#represents the visual representation of a creature on the battlefield

@onready var Sprite= $Sprite
@onready var HealthBar = $HealthBar;

var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

func setCreature(creature:Creature):
	self.creature = creature;
	if creature:
		HealthBar.set_max(creature.getMaxHealth())
		HealthBar.setHealth(creature.getHealth())
		Sprite.sprite_frames = creature.spriteFrame;
		Sprite.play()
		set_visible(true)
		
		creature.took_damage.connect(func (dmg):
			HealthBar.setHealth(creature.getHealth())
			)
	else:
		set_visible(false)
	
#useful if you want to apply a transform to Sprites
func setTransform(transform:Transform2D):
	Sprite.transform = transform
	
func getTransform():
	return Sprite.transform

func getCreature():
	return self.creature
# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween();
	setCreature(null)
	#icon = load("res://sprites/dialga.png")
	pass # Replace with function body.

#gets and restarts the animation
func getTween():
	tween.kill();
	tween = create_tween()
	return tween;





