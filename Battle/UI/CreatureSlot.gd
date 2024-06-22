class_name CreatureSlot extends Button

#represents the visual representation of a creature on the battlefield

@onready var Sprite= $Sprite
@onready var HealthBar = $HealthBar;

const MAX_DIMEN = 200 #max size in either dimension a sprite can be

var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

func setCreature(creature:Creature):
	self.creature = creature;
	if creature:
		HealthBar.set_max(creature.getMaxHealth())
		HealthBar.setHealth(creature.getHealth())
		Sprite.sprite_frames = creature.spriteFrame;
		
		#make sure sprite isnt' too big
		var vec2 = Sprite.sprite_frames.get_frame_texture("default",0).get_size()
		var larger = max(vec2.x,vec2.y)
		if larger >= MAX_DIMEN:
			Sprite.scale = Vector2(MAX_DIMEN/larger,MAX_DIMEN/larger)
		else:
			Sprite.scale = Vector2(1,1)
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





