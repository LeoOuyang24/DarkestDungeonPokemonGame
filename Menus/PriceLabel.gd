class_name PriceLabel extends RichTextLabel


func formatLabel(cost:int,title:String,disabled:bool):
	#label.set_text(title)
	modulate = Color.WHITE if !disabled else Color.DARK_GRAY
	if title.length() > 0:
		set_text("[center]%s\n[img width=32]res://sprites/icons/dna_icon.png[/img]%d[/center]" % [title,cost])
	else:
		set_text("[center][img width=32]res://sprites/icons/dna_icon.png[/img]%d[/center]" % [cost])
