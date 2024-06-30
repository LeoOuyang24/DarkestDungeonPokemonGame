class_name CreatureSlot extends Button

#represents the visual representation of a creature on the battlefield

@export var testing:bool = false

@onready var Sprite= $Sprite
@onready var HealthBar = $HealthBar;

@onready var HealthIcon = $Icons/HealthIcon/Label
@onready var SpeedIcon = $Icons/SpeedIcon/Label
@onready var AttackIcon = $Icons/AttackIcon/Label

const MAX_DIMEN = 200 #max size in either dimension a sprite can be
const HEALTH_MARGIN = 15 #space from top of healthbar to bottom of sprite
var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

func setSize(size:Vector2) -> void:
	Sprite.scale = size/get_size()

func setHeight(height:int) -> void:
	#setSize(Vector2(size.x,height))
	Sprite.scale = (Vector2(0,0))

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

		#adjust position so sprite doesn't block the healthbar
		setTransform(getTransform().translated(Vector2(0,-max(0,Sprite.position.y + Sprite.scale.y*vec2.y/2  - (HealthBar.position.y - HEALTH_MARGIN )))))

		Sprite.play()
		
		set_visible(true)
		
		creature.health.stat_changed.connect(func (dmg,newHealth):
			HealthIcon.set_text(str(newHealth))
			)
		creature.attack.stat_changed.connect(func(a,newAttack):
			AttackIcon.set_text(str(newAttack))
			)	
		creature.speed.stat_changed.connect(func(a,newSpeed):
			SpeedIcon.set_text(str(newSpeed))
			)	
		
		
		HealthIcon.set_text(str(creature.getHealth()))
		AttackIcon.set_text(str(creature.getAttack()))
		SpeedIcon.set_text(str(creature.getSpeed()))
		
		
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
	
	if testing:
		setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))
	#icon = load("res://sprites/dialga.png")
	pass # Replace with function body.

#gets and restarts the animation
func getTween():
	tween.kill();
	tween = create_tween()
	return tween;
