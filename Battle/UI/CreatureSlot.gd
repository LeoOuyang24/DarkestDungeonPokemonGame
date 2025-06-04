class_name CreatureSlot extends Control

#represents the visual representation of a creature on the battlefield

@export var testing:bool = false

signal creature_clicked(creature:Creature)
signal right_clicked()

#@onready var Sprite = $Button
@onready var HealthBar = $HealthBar;
@onready var Animations = %SpriteAnimations;

@onready var Icons = $Icons
@onready var EffectsUI:StatusEffectsUI = %StatusEffectsUI

@onready var Ticker = %DamageTicker
@onready var TickerAnimation = %TickerAnimation
@onready var pendingMove = %PendingMove
@onready var Sprite := %Button

const MAX_DIMEN = 200 #max size in either dimension a sprite can be
var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

func _input(event):
	if event is InputEventMouseButton and event.is_pressed()\
	and get_global_rect().has_point(event.position):
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_clicked.emit()


	
func onPress():
	creature_clicked.emit(getCreature())
	
func _ready():
	Sprite.pressed.connect(onPress)
	size_flags_vertical = SIZE_SHRINK_END
	tween = getTween()
	setCreature(null)
	#if testing:
	#	setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/silent.json"))


#set the sprite and also scale
func setSpriteAndSize(spriteFrames:SpriteFrames,mult:float) -> void:
	Sprite.setSprite(spriteFrames)
	if spriteFrames:
		#make sure sprite isnt' too big
		var larger = mult*max(Sprite.size.x,Sprite.size.y);
		if larger >= MAX_DIMEN:
			mult = MAX_DIMEN/larger;
		Sprite.setSize(mult*Sprite.size)

func removeCreature():
	if creature:
		creature.traits.onRemoveUI(self)
		creature.stats.stat_changed.disconnect(updateHealth)
		creature.statuses.status_added.disconnect(onAddStatus)
		creature.statuses.status_removed.disconnect(onRemoveStatus)
		EffectsUI.clear()
		creature = null
		Sprite.setSprite(null)
		%FlySpacer.visible = false

func onAddStatus(status:StatusEffect):
	status.onAddUI(self);
	EffectsUI.addStatusEffect(status)
	
func onRemoveStatus(status:StatusEffect):
	status.onRemoveUI(self)
	EffectsUI.removeStatusEffect(status)

func updateHealth(stat:CreatureStats.STATS,amount:int):
	if stat == CreatureStats.STATS.HEALTH:
		if (amount < 0):
			Animations.play("hurt")
			#if an attack does over half a creature's health, shake more
			@warning_ignore("integer_division")
			if abs(amount) > creature.stats.getBaseStat(CreatureStats.STATS.HEALTH)/2:
				Game.GameCamera.shake(100)
			else:
				Game.GameCamera.shake(30)
		HealthBar.set_max(creature.stats.getBaseStat(CreatureStats.STATS.HEALTH))
		HealthBar.setHealth(creature.stats.getCurStat(CreatureStats.STATS.HEALTH))

		Ticker.clear()
		Ticker.push_color(Color.RED if amount < 0 else ( Color.GREEN  if amount > 0 else Color.BLACK)) #if healing, text color is green
		Ticker.append_text(("+" if amount > 0 else "") + str(amount)) #add a "+" sign if healing
		Ticker.pop()
		TickerAnimation.play("hurt")	

#override parent on hover
func onHover():
	pass

func setCreature(c:Creature):
	removeCreature()
	self.creature = c;
	pendingMove.PendingMove.creature = c
	if c:

		var sprite = c.spriteFrame
		setSpriteAndSize(sprite,c.scale)
		if (HealthBar):
			HealthBar.set_max(c.stats.getBaseStat(CreatureStats.STATS.HEALTH))
			HealthBar.setHealth(creature.stats.getCurStat(CreatureStats.STATS.HEALTH))
		creature.stats.stat_changed.connect(updateHealth)
		EffectsUI.update(creature.statuses)
		creature.statuses.status_added.connect(onAddStatus)
		creature.statuses.status_removed.connect(onRemoveStatus)
		c.traits.onAddUI(self)
		EffectsUI.position.x = HealthBar.size.x if c.getIsFriendly() else 0

		Sprite.set_flip_h( c.getIsFriendly())
		EffectsUI.setIsOnEnemy(c.getIsFriendly())
					
		%FlySpacer.visible = c.flying
	else:
		#there are weird complications with the BattleUI rows if we just make the
		#creatureslot invisible. For example, all the invisible slots will be crammed into
		#one space, which makes battlefield's debug controls weird.
		setSpriteAndSize(null,1)
		
	if HealthBar:
		HealthBar.visible = (c != null)

		
	
func setAnimation(string:String) -> void:
	Sprite.changeAnimation(string)

func getCreature():
	return self.creature

func _to_string() -> String:
	return "[Creature Slot: " + (creature.to_string() if creature else "null") + "]"

func getTween():
	if tween:
		tween.kill()
	tween = create_tween()
	return tween;
