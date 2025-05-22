class_name CreatureSlot extends AnimatedButton

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
@onready var PendingMove = %PendingMove

const MAX_DIMEN = 200 #max size in either dimension a sprite can be
var tween = null
#a reference to the creature we are referring to
var creature:Creature = null 

func _input(event):
	if event is InputEventMouseButton and event.is_pressed()\
	and get_global_rect().has_point(event.position):
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_clicked.emit()


	
func _pressed():
	creature_clicked.emit(getCreature())
	
func _ready():
	size_flags_vertical = SIZE_SHRINK_END
	tween = getTween()
	setCreature(null)
	if testing:
		setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))


#set the sprite and also scale
func setSpriteAndSize(spriteFrames:SpriteFrames,scale:float) -> void:
	setSprite(spriteFrames)
	if spriteFrames:
		#make sure sprite isnt' too big
		var larger = scale*max(size.x,size.y);
		if larger >= MAX_DIMEN:
			scale = MAX_DIMEN/larger;
		setSize(scale*size)

func removeCreature():
	if creature:
		creature.traits.onRemoveUI(self)
		creature.stats.stat_changed.disconnect(updateHealth)
		creature.statuses.status_added.disconnect(onAddStatus)
		creature.statuses.status_removed.disconnect(onRemoveStatus)
		EffectsUI.clear()
		creature = null
		setSprite(null)

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

func setCreature(creature:Creature):
	removeCreature()
	self.creature = creature;
	PendingMove.PendingMove.creature = creature
	if creature:

		var sprite = creature.spriteFrame
		setSpriteAndSize(sprite,creature.scale)
		if (HealthBar):
			HealthBar.set_max(creature.stats.getBaseStat(CreatureStats.STATS.HEALTH))
			HealthBar.setHealth(creature.stats.getCurStat(CreatureStats.STATS.HEALTH))
		creature.stats.stat_changed.connect(updateHealth)
		EffectsUI.update(creature.statuses)
		creature.statuses.status_added.connect(onAddStatus)
		creature.statuses.status_removed.connect(onRemoveStatus)
		creature.traits.onAddUI(self)
		EffectsUI.position.x = HealthBar.size.x if creature.getIsFriendly() else 0

		set_flip_h( creature.getIsFriendly())
		EffectsUI.setIsOnEnemy(creature.getIsFriendly())
					
	else:
		Resources.highlight(self,Color(0,0,0,0));
		setSpriteAndSize(null,0)
	if HealthBar:
		HealthBar.visible = (creature != null)

		
	
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
