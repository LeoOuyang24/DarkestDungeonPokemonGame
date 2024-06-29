class_name StatBar extends Control

#represents a bar of a stat in the bargraph in the CreatureSummary Scene

@onready var StatLabel = $Label
@onready var Bar = $ColorRect
@onready var Icon = $Icon
@onready var BigBoost = $BigBoost

@export var BarColor:Color = Color.GREEN
@export var Sprite:Texture = null

var width=10#width per unit of the stat
var maxWidth:int = width*Creature.MAX_LEVEL #most amount of width we have to work with

var creature:Creature = null
var stat:Creature.STATS = Creature.STATS.HEALTH #which stat we represent

#the actual amount of the stat we are displaying
var val:int = 0

func setVal(amount:int) -> void:
	val = amount
	StatLabel.set_text(str(amount))
	StatLabel.position.x = Bar.position.x + Bar.size.x

#visually grow to a size, starint at startSTat
func growTo(newStat:int = val, startStat:int = 0) -> void:
	var tween = create_tween()

	setVal(startStat)

	tween.parallel().tween_property(Bar,"size",Vector2(newStat*width,Bar.size.y),1)
	tween.parallel().tween_method(setVal,0,newStat,1)

#set the bonus, or disable the bonus if the bonus is 0
func setBonus(bonus:int,color:Color=Color.GREEN):
	if bonus != 0:
		StatLabel.set_text(str(val)+"[color=" + color.to_html()+"]+"+str(bonus)+"[/color]")
	else:
		StatLabel.set_text(str(val))
	#Bonuses.set_position(Vector2(StatLabel.position.x + StatLabel.size.x + 10, StatLabel.position.y))

func setCreature(creature:Creature, stat:Creature.STATS):
	self.creature = creature
	self.stat = stat
	if creature:
		growTo(creature.getBaseStat(stat))
		var tracker = creature.getStatTracker(stat)
		creature.stat_changed.connect(func(stat:Creature.STATS,amount):
			if stat == self.stat:
				growTo(creature.getBaseStat(stat))
			BigBoost.set_visible(creature.getPendingBigBoosts()>0)
			)
	

func setMaxWidth(maxWidth:int) -> void:
	self.maxWidth = maxWidth
	self.width = (maxWidth-10)/Creature.MAX_LEVEL
	BigBoost.position = Vector2(Bar.position.x + width*(Creature.MAX_LEVEL + 10),StatLabel.position.y)

func _ready():
	Bar.color = BarColor
	Icon.texture = Sprite
	setMaxWidth(maxWidth)
	
	#setBonus(10)
	#growTo(100)
	pass

func _on_big_boost_mouse_entered():
	setBonus(Stat.BIG_BOOST_AMOUNT,Color.BLUE)
	pass # Replace with function body.


func _on_big_boost_mouse_exited():
	setBonus(0)
	pass # Replace with function body.

func _on_big_boost_pressed():
	if creature:
		creature.bigBoostStat(self.stat)
