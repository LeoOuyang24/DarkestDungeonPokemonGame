class_name QueueSlot extends AnimatedButton

@onready var SpeedCounter = $SpeedCounter
@onready var Background = $Background

var creature:Creature = null

func updateSpeed(speed:int = creature.stats.getCurStat(CreatureStats.STATS.SPEED) if creature else 0) -> void:
	SpeedCounter.set_text(str(speed))

func setCreature(creature:Creature) -> void:
	self.creature = creature
	if creature:
		visible = true
		setSprite(creature.getSprite())
		updateSpeed()
		creature.stats.stat_changed.connect(updateSpeed)
		Background.color = Color(0,1,0,0.2) if creature.getIsFriendly() else Color(1,0,0,0.2)
	else:
		visible = false
		
func _get_tooltip (at_position:Vector2 ):
	if creature:
		return creature.getName() + " has a speed of " + str(creature.getSpeed()) + "." 
	return ""
		
#overrides the parent constructor which prevents the parent class from overwriting stretch mode
func _init():
	pass	
