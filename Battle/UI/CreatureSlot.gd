class_name CreatureSlot extends AnimatedButton

#represents the visual representation of a creature on the battlefield

@export var testing:bool = false


#@onready var Sprite = $Button
@onready var HealthBar = $HealthBar;
@onready var Animations = $SpriteAnimations;

@onready var Icons = $Icons
@onready var HealthIcon = Icons.get_node("HealthIcon/Label")
@onready var SpeedIcon = Icons.get_node("SpeedIcon/Label")
@onready var AttackIcon = Icons.get_node("AttackIcon/Label")
@onready var Attack = Icons.get_node("AttackIcon")

@onready var Ticker = $DamageTicker
@onready var TickerAnimation = $DamageTicker/Animation

const MAX_DIMEN = 200 #max size in either dimension a sprite can be
const HEALTH_MARGIN = 15 #space from top of healthbar to bottom of sprite
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
			#scale = Vector2(MAX_DIMEN/larger,MAX_DIMEN/larger)
			setSize(Vector2(MAX_DIMEN,MAX_DIMEN))
		else:
			setSize(newsize)
		custom_minimum_size = size


func setCreature(creature:Creature):
	self.creature = creature;
	if creature:
		var sprite = creature.spriteFrame
		setSprite(sprite)
			
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
		
		set_flip_h( creature.getIsFriendly())
		#position.x *= int(creature.getIsFriendly())*2-1
		Icons.global_position.x = HealthBar.global_position.x + (HealthBar.size.x -Icons.size.x if creature.getIsFriendly() else 0)
		Icons.global_position.y = HealthBar.global_position.y - Icons.size.y
	else:
		setSprite(null)
	Attack.visible = creature != null
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
# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween();
	setCreature(null)
	
	if testing:
		setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))
	#setSize(Vector2(100,100))
	#setSize(Vector2(50,50))
	#icon = load("res://sprites/dialga.png")
	pass # Replace with function body.

#gets and restarts the animation
func getTween():
	tween.kill();
	tween = create_tween()
	return tween;
