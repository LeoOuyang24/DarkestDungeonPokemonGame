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

	if !move.isUsable():
		label.append_text(str(move.getRemainingCD()) + " turns left before move can be used.")
	else:
		var regex = RegEx.new()
		#regex that detects "Deal X damage". Allows for any number before the X. 
		#The number can be either an int or a decimal. The decimal must have a number before the decimal point (0.1 is okay but .1 is not)
		regex.compile("{{(((?<leading>\\d+(\\.\\d+)?)x((?<operator>[\\+\\-])(?<yinterp>\\d+))?)|(?<constant>\\d+))}}") 
		#highlight any keywords
		var result = regex.search_all(summary)
		var start:int = 0

		if result:
			var values = move.getModifiers(null)
			for i in range(result.size()):
				var found = result[i]
				var modifier = values[i] if values.size() < i else {"value":10,"color":Color.RED}
				var val := 0
				if found.get_string("constant"):
					val = int(found.get_string("constant"))
				else:
					val = int(found.get_string("leading"))*modifier.value
					if found.get_string("operator") == "+":
						val += int(found.get_string("yinterp"))
					else:
						val -= int(found.get_string("yinterp"))
				var regexStart = found.get_start(0)
				var regexEnd = found.get_end(0)
				#add the text before keyword
				label.append_text(summary.substr(start,regexStart-start))
				#bolden and add keyword
				label.push_bold()
				label.push_color(modifier.color)
				label.append_text(str(val))
				label.pop()
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
	
#return the given creature's stat as a string, formatted the way it'd appear in the description
static func getCreatureStatUI(creature:Creature, stat:Creature.STATS) -> String:
	if creature:
		var label = RichTextLabel.new()
		label.push_color(Color.RED)
		label.append_text(str(creature.getStat(stat)))
		label.pop()
		return label.text
	return ""
