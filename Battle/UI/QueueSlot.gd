class_name QueueSlot extends Button

@onready var SpeedCounter:RichTextLabel = $SpeedCounter
@onready var Background:PanelContainer = $PanelContainer
@onready var PendingMove:Control = %PendingMove
@onready var Sprite:Anime = %Anime

var creature:Creature  = null

func updateSpeed(speed:int = creature.stats.getCurStat(CreatureStats.STATS.SPEED) if creature else 0) -> void:
	SpeedCounter.set_text("[outline_color=black][outline_size=10][font_size=25]"+str(speed)+"[/font_size][/outline_size][/outline_color]")

func setColor(color:Color) -> void:
	Background["theme_override_styles/panel"].set("bg_color",color)
	PendingMove["theme_override_styles/panel"].set("bg_color",color)

func setCreature(creature:Creature) -> void:
	self.creature = creature
	PendingMove.creature = creature
	if creature:
		visible = true
		Sprite.setSprite(creature.getSprite())
		updateSpeed()
		creature.stats.stat_changed.connect(updateSpeed)
		setColor(Color(1,.7,.1,0.2) if creature.getIsFriendly() else Color(.5,.5,.5,0.2))
		#Background.color = Color(1,.7,.1,0.2) if creature.getIsFriendly() else Color(.5,.5,.5,0.2)
	else:
		visible = false
		
func _get_tooltip (at_position:Vector2 ):
	if creature:
		return creature.getName() + " has a speed of " + str(creature.stats.getStatObj(CreatureStats.STATS.SPEED).getStat()) + "." 
	return ""
