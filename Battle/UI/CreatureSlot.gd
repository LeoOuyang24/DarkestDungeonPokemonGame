class_name CreatureSlot extends Control

#represents the visual representation of a creature on the battlefield

@export var testing:bool = false


@onready var Sprite = $Button
@onready var HealthBar = $HealthBar;
@onready var Animations = $Button/Animations;

@onready var HealthIcon = $Icons/HealthIcon/Label
@onready var SpeedIcon = $Icons/SpeedIcon/Label
@onready var AttackIcon = $Icons/AttackIcon/Label

const MAX_DIMEN = 200 #max size in either dimension a sprite can be
const HEALTH_MARGIN = 15 #space from top of healthbar to bottom of sprite
var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

func getConnection()-> Signal:
	return Sprite.pressed

#overrides the AnimatedButton setSprite
func setSprite(spriteFrames:SpriteFrames) -> void:
	Sprite.setSprite(spriteFrames)
	#Sprite.sprite_frames = spriteFrames;
	
	#make sure sprite isnt' too big
	var vec2 = Sprite.sprite.getFrameSize()
	var larger = max(vec2.x,vec2.y)
	if larger >= MAX_DIMEN:
		#Sprite.scale = Vector2(MAX_DIMEN/larger,MAX_DIMEN/larger)
		Sprite.setSize(Vector2(MAX_DIMEN,MAX_DIMEN))
	#else:
		#Sprite.scale = Vector2(1,1)
	#adjust position so sprite doesn't block the stats
	#I feel like there's an easier way to do this but I don't know it lmao
	#grow direction didn't work for me
	Sprite.position.y = -Sprite.size.y


func setCreature(creature:Creature):
	self.creature = creature;
	if creature:
		setSprite(creature.spriteFrame)
		#set_visible(true)
		if (HealthBar):
			HealthBar.set_max(creature.getMaxHealth())
			HealthBar.setHealth(creature.getHealth())
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
		
		creature.health_changed.connect(healthChanged)
		
		Sprite.sprite.flip_h = creature.getIsFriendly()
	#else:
		#set_visible(false)
	
func healthChanged(damage:int,_newHealth:int) -> void:
	if (damage < 0):
		Animations.play("hurt")
		
	
func setAnimation(string:String) -> void:
	Sprite.changeAnimation(string)

func getCreature():
	return self.creature
# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween();
	setCreature(null)
	
	if testing:
		setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/silent.json"))
	#setSize(Vector2(100,100))
	#Sprite.setSize(Vector2(50,50))
	#icon = load("res://sprites/dialga.png")
	pass # Replace with function body.

#gets and restarts the animation
func getTween():
	tween.kill();
	tween = create_tween()
	return tween;
