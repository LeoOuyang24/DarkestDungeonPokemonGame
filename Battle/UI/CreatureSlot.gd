class_name CreatureSlot extends AnimatedButton

#represents the visual representation of a creature on the battlefield

@export var testing:bool = false


#@onready var Sprite = $Button
@onready var HealthBar = $HealthBar;
@onready var Animations = $SpriteAnimations;

@onready var Icons = $Icons

@onready var Ticker = $DamageTicker
@onready var TickerAnimation = $DamageTicker/Animation

const MAX_DIMEN = 300 #max size in either dimension a sprite can be
var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

#overrides the AnimatedButton setSprite
func setSprite(spriteFrames:SpriteFrames) -> void:
	super(spriteFrames)
	if spriteFrames:
		var newsize = sprite.getFrameSize()
		custom_minimum_size = Vector2(0,0)
		#make sure sprite isnt' too big
		var larger = max(newsize.x,newsize.y)
		if larger >= MAX_DIMEN:
			setSize(Vector2(MAX_DIMEN,MAX_DIMEN))
		else:
			setSize(newsize)
		custom_minimum_size = size

func setCreature(creature:Creature):
	self.creature = creature;
	if creature:
		var sprite = creature.spriteFrame
		setSprite(sprite)
		if (HealthBar):
			HealthBar.set_max(creature.getMaxHealth())
			HealthBar.setHealth(creature.getHealth())
		creature.health_changed.connect(healthChanged)
		set_flip_h( creature.getIsFriendly())
	else:
		setSprite(null)
		
	HealthBar.visible = creature != null
		
	
func healthChanged(damage:int,newHealth:int) -> void:
	if (damage != 0):
		if (damage < 0):
			Animations.play("hurt")
		HealthBar.setHealth(newHealth)
		Ticker.clear()
		Ticker.push_color(Color.RED if damage < 0 else Color.GREEN) #if healing, text color is green
		Ticker.append_text(("+" if damage > 0 else "") + str(damage)) #add a "+" sign if healing
		Ticker.pop()
		TickerAnimation.play("hurt")
		
	
func setAnimation(string:String) -> void:
	changeAnimation(string)

func getCreature():
	return self.creature
	
func _ready():
	tween = getTween()
	setCreature(null)
	if testing:
		setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))

func getTween():
	if tween:
		tween.kill()
	tween = create_tween()
	return tween;
