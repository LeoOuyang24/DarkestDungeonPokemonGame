class_name StatBar extends Control

#represents a stat's bargraph in the CreatureSummary Scene

@onready var StatLabel = $Labels/Label
@onready var Bar = $ColorRect
@onready var Bonuses = $Labels/Bonuses #used to print out what a stat would be after levelup
@onready var Labels = $Labels #control used to synchronize the movement of both rich text labels. PRobably an easier way to do this tbh
@onready var Icon = $Icon

@export var BarColor:Color = Color.GREEN
@export var Sprite:Texture = null

static var width=10#width per unit of the stat

func setVal(stat:int) -> void:
	StatLabel.set_text(str(stat))
	#Bar.size.x = width*stat
	Labels.position.x = Bar.position.x + Bar.size.x

#visually grow to a size
func growTo(stat:int) -> void:
	var tween = create_tween()

	tween.parallel().tween_property(Bar,"size",Vector2(stat*width,Bar.size.y),1)
	tween.parallel().tween_method(setVal,0,stat,1)

#set the bonus, or disable the bonus if the bonus is 0
func setBonus(bonus:int):
	if bonus == 0:
		Bonuses.set_visible(false)
	else:
		Bonuses.set_text("+"+str(bonus))
		Bonuses.set_visible(true)
	#Bonuses.set_position(Vector2(StatLabel.position.x + StatLabel.size.x + 10, StatLabel.position.y))



func _ready():
	Bar.color = BarColor
	Icon.texture = Sprite
	
	#setBonus(10)
	#growTo(100)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
