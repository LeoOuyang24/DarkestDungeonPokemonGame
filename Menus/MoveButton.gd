class_name MoveButton extends Button

# a generic button that shows a move
#does not worry about cooldowns or anything like that

var move:Move = null
var creature:Creature = null

static var popup = preload("res://UI/OnHoverUI.tscn")

signal move_selected(move:Move)
signal right_clicked()

func setMove(move_:Move,creature_:Creature = null) -> void:
	move = move_
	if move:
		self.text = move.getMoveName()
	else:
		self.text = ""
	creature = creature_;

static func getMoveTooltip(move:Move,creature:Creature) -> Control:
	if move:
		var label = RichTextLabel.new()
		label.custom_minimum_size = Vector2(200,0)
		label.fit_content = true
		label.bbcode_enabled = true
		label.theme = load("res://Battle/UI/MoveButton.tres")

		var tooltip = popup.instantiate()
		tooltip.setName(move.getMoveName())
		tooltip.setIcon(move.icon)
		
		var values = move.getModifiers(creature)
		#convert each modifier to a string
		#this is done by taking the value and adding in the color
		#if the creature is null, we instead show a formula (1x damage, 2.5x damage, etc)
		values = values.map(func(obj):
			#if creature:
				#var val:int = obj.value if obj.value else -1
				#var color:Color = obj.color if obj.color else Color.RED
				#return ("[color=%s]%d[/color]") % [color.to_html(),val]
			#else:
			return obj.calc #for now, let's only do the calculation
				
			)
		#color each damage calc with yellow and bold
		var summary := move.summary % values
		var string := ""
		var regex := RegEx.new()
		regex.compile("([0-9]*\\.?)([0-9]+)x")
		var i := 0;
		for result in regex.search_all(summary):
			string += summary.substr(i,result.get_start() - i) + ("[b][color=%s]" % Color.YELLOW.to_html()) + result.get_string() + "[/color][/b]"
			i = result.get_end()
		string += summary.substr(i,summary.length() - i)
		#var string = move.summary % values;
		if move.slot and !move.slot.isUsable():
			string += ("\n[color=RED]" + str(move.slot.getRemainingCD()) + " turns left before move can be used.[/color]")
		
		string += "\n\nTargets: " + str(move.manualTargets);
		
		tooltip.setMessage(string)
		
		return tooltip	
	return null
	
#makes the tooltip for each button, which changes dynamically 
#ie, having more attack will change the damage number
func _make_custom_tooltip(summary:String):
	if move:
		return getMoveTooltip(move,creature)
	return ""

			
func getMove() -> Move:
	return move
	
func _pressed() -> void:
	move_selected.emit(move)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed()\
	and get_global_rect().has_point(event.position):
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_clicked.emit()
