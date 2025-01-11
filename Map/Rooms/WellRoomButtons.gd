extends Button

@export var tooltipColor:Color = Color.WHITE

var popup := load("res://UI/OnHoverUI.tscn")

func _make_custom_tooltip(summary:String):
	var label = Label.new()
	label.set_text(summary);
	label.add_theme_color_override("font_color",tooltipColor)
	
	return label
		
