class_name CostButton extends BaseButton

#a button that disables itself if we can't afford it
#add this script to any button you want to have this functionality

#a rich text label that is expected to be a PriceLabel. Is modified to reflect price
#still works even if label is null
@onready var label = %Label

#used by child classes to calculate if the button should be disabled
#so for example, maybe you need the button to be disabled if you can't afford it OR
#nothing has been selected. You'd set "disable" for the latter case
var disable:bool = false:
	set(val):
		disable = val
		toggle(GameState.getDNA())

@export var title:String = ""
@export var cost:int = 0:
	set(val):
		cost = val
		toggle(GameState.getDNA())
		if label and label is PriceLabel:
			label.formatLabel(cost,title,is_disabled())
	
func applyCost():
	GameState.setDNA(GameState.getDNA() - cost)

func _init():
	GameState.DNA_changed.connect(toggle)
	
func toggle(amount:int):
	set_disabled(disable || cost > amount)
		
func _pressed():
	applyCost()
