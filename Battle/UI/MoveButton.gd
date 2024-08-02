class_name MoveButton extends Button

var move:Move = null

signal move_selected(move:Move)

func _ready():
	pass # Replace with function body.

func setMove(move:Move) -> void:
	self.move = move
	if move:
		self.text = move.getMoveName()
		self.move.cooldown_changed.connect(cdChanged)
		cdChanged(0,0)
		set_tooltip_text(move.summary +"\nCooldown: " + str(move.baseCooldown))
	else:
		self.text = ""
		set_tooltip_text("")
	
func _make_custom_tooltip(summary:String):
	var label = RichTextLabel.new()
	label.custom_minimum_size = Vector2(200,0)
	label.fit_content = true
	#label.offset_bottom = 100
	#label.anchor_bottom = SIDE_BOTTOM
	#label.anchors_preset = PRESET_CENTER_BOTTOM
	if !move.isUsable():
		label.append_text(str(move.getRemainingCD()) + " turns left before move can be used.")
	else:
		var regex = RegEx.new()
		#regex that detects "Deal X damage". Allows for any number before the X. 
		#The number can be either an int or a decimal. The decimal must have a number before the decimal point (0.1 is okay but .1 is not)
		regex.compile("[dD]eal (\\d+(\\.\\d+)?(\\+x|x)?)") 
		#highlight any keywords
		var result = regex.search_all(summary)
		var start:int = 0
		#label.pivot_offset = Vector2(0,size.y)
		#label.append_text("asoidfuasoidfussoiduffffdsoifudsofisufosiudfosidufosidfusoidfsudofisuf\n\n\n\n\n\n\n")
		if result:
			for i in result:
				var regexStart = i.get_start(1)
				var regexEnd = i.get_end(1)
				#add the text before keyword
				label.append_text(summary.substr(start,regexStart-start))
				#bolden and add keyword
				label.push_bold()
				label.append_text(summary.substr(regexStart,regexEnd - regexStart))
				label.pop()
				
				start = regexEnd
			label.append_text(summary.substr(start,-1))
		else:
			label.append_text(summary)
		#label.push_font_size(15)

	return label
	
func cdChanged(_amount:int,_newCD:int) -> void:
	if move:
		if move.isUsable():
			self.text = move.getMoveName()
			self.disabled = false
		else:
			self.text = str(move.getRemainingCD())
			self.disabled = true
			
func getMove() -> Move:
	return move
	
func _pressed() -> void:
	move_selected.emit(move)
