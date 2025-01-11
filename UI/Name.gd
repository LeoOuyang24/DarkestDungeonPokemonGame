extends RichTextLabel

#used for the Creature name in CreatureSummary. Displays what traits do when hovered over.

var popup := load("res://UI/OnHoverUI.tscn")

var creature:Creature = null;

func _make_custom_tooltip(summary:String):
	if creature and creature.traits.getAllStatuses().size() > 0:
		var vbox = VBoxContainer.new()
		for t in creature.traits.getAllStatuses():
			var tooltip = popup.instantiate()
			
			var tr:Trait = creature.traits.getStatus(t)
			tooltip.setName(tr.name)
			tooltip.setMessage(tr.getTooltip())
			
			vbox.add_child(tooltip)
		
		return vbox
	return null
