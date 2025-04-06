class_name MoveButton extends Button

var slot:MoveSlot= null
var creature:Creature = null

static var popup = preload("res://UI/OnHoverUI.tscn")

signal move_selected(move:Move)

func _ready():
	pass # Replace with function body.

func setSlot(slot:MoveSlot, creature:Creature) -> void:
	self.slot = slot
	self.creature = creature
	
	if slot:
		setMove(slot.move)

func setMove(move:Move) -> void:
	if !slot: #this should really only occur if this button is not associated with a creature
		self.slot = MoveSlot.new()
	self.slot.move = move
	if move:
		#self.move.cooldown_changed.connect(cdChanged)
		#cdChanged(0,0)
		set_tooltip_text(move.summary +"\nCooldown: " + str(move.baseCooldown))
	else:
		set_tooltip_text("")
	
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
	return getMoveTooltip(slot.getMove(),creature)

			
func getMove() -> Move:
	return slot.move if slot else null
	
func _pressed() -> void:
	move_selected.emit(slot.move if slot else null)
	
func _process(delta:float) -> void:
	if slot:
		if slot.isUsable():
			self.text = slot.getMove().getMoveName()
			self.disabled = false
		else:
			self.disabled = true	
			self.text = str(slot.getRemainingCD()) if slot.move else ""
