class_name CreatureSlot extends AnimatedButton

#represents the visual representation of a creature on the battlefield

@export var testing:bool = false


#@onready var Sprite = $Button
@onready var HealthBar = $HealthBar;
@onready var Animations = %SpriteAnimations;

@onready var Icons = $Icons
@onready var EffectsUI:StatusEffectsUI = %StatusEffectsUI

@onready var Ticker = %DamageTicker
@onready var TickerAnimation = %TickerAnimation

const MAX_DIMEN = 150 #max size in either dimension a sprite can be
var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

func _input(event):
	if event is InputEventMouseButton:
		print(get_global_rect().has_point(event.position))


	
func _ready():
	size_flags_vertical = SIZE_SHRINK_END
	tween = getTween()
	setCreature(null)
	if testing:
		setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))
	
	#for debugging purposes, clicking on a creature slot will print the creature
	pressed.connect(func():
		print(creature)
		)

	
func getMaterial() -> Material:
	return material	



func setSpriteAndSize(spriteFrames:SpriteFrames,size:Vector2) -> void:
	setSprite(spriteFrames)
	if spriteFrames:
		var newsize = 2*size
		#make sure sprite isnt' too big
		var larger = max(newsize.x,newsize.y)
		if larger >= MAX_DIMEN:
			setSize(Vector2(MAX_DIMEN,MAX_DIMEN))
		else:
			setSize(newsize)

func removeCreature():
	if creature:
		creature.traits.onRemoveUI(self)
		creature.stats.stat_changed.disconnect(updateHealth)
		creature.statuses.status_added.disconnect(EffectsUI.addStatusEffect)
		creature.statuses.status_removed.disconnect(EffectsUI.removeStatusEffect)
		EffectsUI.clear()
		creature = null
		setSprite(null)

func updateHealth(stat:CreatureStats.STATS,amount:int):
	if stat == CreatureStats.STATS.HEALTH:
		if (amount < 0):
			Animations.play("hurt")
			Game.GameCamera.shake()
		HealthBar.setHealth(creature.stats.getCurStat(CreatureStats.STATS.HEALTH))

		Ticker.clear()
		Ticker.push_color(Color.RED if amount < 0 else ( Color.GREEN  if amount > 0 else Color.WHITE)) #if healing, text color is green
		Ticker.append_text(("+" if amount > 0 else "") + str(amount)) #add a "+" sign if healing
		Ticker.pop()
		TickerAnimation.play("hurt")	

#override parent on hover
func onHover():
	pass

func setCreature(creature:Creature):
	removeCreature()
	self.creature = creature;
	if creature:

		var sprite = creature.spriteFrame
		setSpriteAndSize(sprite,creature.size)
		if (HealthBar):
			HealthBar.set_max(creature.stats.getBaseStat(CreatureStats.STATS.HEALTH))
			HealthBar.setHealth(creature.stats.getCurStat(CreatureStats.STATS.HEALTH))
		creature.stats.stat_changed.connect(updateHealth)
		EffectsUI.update(creature.statuses)
		creature.statuses.status_added.connect(EffectsUI.addStatusEffect)
		creature.statuses.status_removed.connect(EffectsUI.removeStatusEffect)
		creature.traits.onAddUI(self)
		EffectsUI.position.x = HealthBar.size.x if creature.getIsFriendly() else 0

		set_flip_h( creature.getIsFriendly())
		EffectsUI.setIsOnEnemy(creature.getIsFriendly())
	else:
		setOutlineColor(Color(0,0,0,0));
		setSpriteAndSize(null,Vector2(0,0))
		
	HealthBar.visible = creature != null
		
	
func setAnimation(string:String) -> void:
	changeAnimation(string)

func getCreature():
	return self.creature

func _to_string() -> String:
	return "[Creature Slot: " + (creature.to_string() if creature else "null") + "]"

func getTween():
	if tween:
		tween.kill()
	tween = create_tween()
	return tween;


func _on_button_pressed():
	pressed.emit();
	pass # Replace with function body.
