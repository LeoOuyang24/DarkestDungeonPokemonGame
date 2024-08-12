class_name MoveButton extends Button

var move:Move = null
var creature:Creature = null

signal move_selected(move:Move)

func _ready():
	pass # Replace with function body.

func setMove(move:Move,creature:Creature) -> void:
	self.move = move
	self.creature = creature
	if move:
		self.text = move.getMoveName()
		self.move.cooldown_changed.connect(cdChanged)
		cdChanged(0,0)
		set_tooltip_text(move.summary +"\nCooldown: " + str(move.baseCooldown))
	else:
		self.text = ""
		set_tooltip_text("")
	
#makes the tooltip for each button, which changes dynamically 
#ie, having more attack will change the damage number
func _make_custom_tooltip(summary:String):
	var label = RichTextLabel.new()
	label.custom_minimum_size = Vector2(200,0)
	label.fit_content = true
	label.bbcode_enabled = true

	if !move.isUsable():
		label.append_text(str(move.getRemainingCD()) + " turns left before move can be used.")
	else:
		#get modifiers
		var values = move.getModifiers(creature)
		#convert each modifier to a string
		#this is done by taking the value and adding in the color
		#if the creature is null, we instead show a formula (1x damage, 2.5x damage, etc)
		values = values.map(func(obj):
			if creature:
				var val:int = obj.value if obj.value else -1
				var color:Color = obj.color if obj.color else Color.RED
				return ("[color=%s]%d[/color]") % [color.to_html(),val]
			else:
				return obj.calc
				
			)
		label.text = move.summary % values
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

