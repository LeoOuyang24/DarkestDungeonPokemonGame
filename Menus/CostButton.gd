class_name CostButton extends BaseButton

#a button that disables itself if we can't afford it
#add this script to any button you want to have this functionality

#a rich text label that is expected to be a PriceLabel. Is modified to reflect price
#still works even if label is null
@onready var label = %Label


@export var title:String = ""
@export var cost:int = 0;

	
func applyCost():
	GameState.setDNA(GameState.getDNA() - cost)

func _process(delta):
	set_disabled(GameState.getDNA() < cost)
	if label and label is PriceLabel:
		label.formatLabel(cost,title,is_disabled())
		
func _pressed():
	applyCost()
