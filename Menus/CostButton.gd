class_name CostButton extends Button

#a text button that disables itself if we can't afford it

@onready var label = %Label
@onready var comp = $CostComponent
@export var title:String = ""

var textColor:Color = Color.WHITE #used solely to change the label's color

func _ready():
	formatLabel()

func formatLabel(title:String=self.title):
	modulate = textColor
	#label.set_text(title)
	label.set_text("[center]%s\n[img width=32]res://sprites/icons/dna_icon.png[/img]%d[/center]" % [title,comp.cost])

func _on_cost_component_cost_changed(newCost):
	if label:
		formatLabel()
	pass # Replace with function body.

func setDisabled(d:bool) -> void:
	set_disabled(d)
	if label:
		textColor = Color.WHITE if !d else Color.DARK_GRAY
		formatLabel()	

func _on_cost_component_can_afford(not_broke):
	setDisabled(!not_broke)
	pass # Replace with function body.

func setCost(cost:int)-> void:
	comp.cost = cost
