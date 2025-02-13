class_name StatBar extends Control

#represents a bar of a stat in the bargraph in the CreatureSummary Scene

@onready var StatLabel:RichTextLabel = $Label
@onready var Bar := $ProgressBar
@onready var Icon:TextureRect = $Icon
@onready var BigBoost:TextureButton = $BigBoost

@export var BarColor:Color = Color.GREEN

var popup := load("res://UI/OnHoverUI.tscn");

var width=10#width per unit of the stat
var maxWidth:int = width*CreatureLevel.MAX_LEVEL #most amount of width we have to work with

var creature:Creature = null
var stat:CreatureStats.STATS = CreatureStats.STATS.HEALTH #which stat we represent

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
	tween.parallel().tween_method(Bar.set_value,startStat,newStat,1)
	#tween.parallel().tween_property(Bar,"size",Vector2(newStat*width,Bar.size.y),1)
	tween.parallel().tween_method(setVal,0,newStat,1)

#set the bonus, or disable the bonus if the bonus is 0
func setBonus(bonus:int,color:Color=Color.GREEN):
	if bonus != 0:
		StatLabel.set_text(str(val)+"[color=" + color.to_html()+"]+"+str(bonus)+"[/color]")
	else:
		StatLabel.set_text(str(val))
	#Bonuses.set_position(Vector2(StatLabel.position.x + StatLabel.size.x + 10, StatLabel.position.y))

func setCreature(creature:Creature, stat:CreatureStats.STATS):
	self.creature = creature
	self.stat = stat
	if creature:
		onStatChanged(stat,creature.stats.getCurStat(stat))
		var tracker = creature.stats.getStatObj(stat)
		creature.stats.stat_changed.connect(onStatChanged)
	
func onStatChanged(stat:CreatureStats.STATS,amount):
	if stat == self.stat:
		growTo(creature.stats.getCurStat(stat))
	BigBoost.set_visible(creature.level.getPendingBigBoosts()>0)
	
#set the maximum width our bar can grow to
func setMaxWidth(maxWidth:int) -> void:
	self.maxWidth = maxWidth
	self.width = (maxWidth-10)/CreatureLevel.MAX_LEVEL

func _make_custom_tooltip(_text:String):
	var tooltip = popup.instantiate();
	tooltip.setIcon(Icon.get_texture())
	tooltip.setName(CreatureStats.getStatName(stat))
	tooltip.setMessage(CreatureStats.getStatDescription(stat))
	
	return tooltip

func _ready():
	#\Bar.get("theme_override_styles/fill").bg_color = BarColor
	#Bar.custom_minimum_size.x = get_parent_control().get_size().x

	setBonus(10)
	growTo(100)
	pass

func _on_big_boost_mouse_entered():
	setBonus(Stat.BIG_BOOST_AMOUNT,Color.BLUE)
	pass # Replace with function body.


func _on_big_boost_mouse_exited():
	setBonus(0)
	pass # Replace with function body.

func _on_big_boost_pressed():
	if creature:
		creature.addBigBoost(stat,1)
