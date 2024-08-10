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
	
func _make_custom_tooltip(summary:String):
	var label = RichTextLabel.new()
	label.custom_minimum_size = Vector2(200,0)
	label.fit_content = true
	label.bbcode_enabled = true

	if !move.isUsable():
		label.append_text(str(move.getRemainingCD()) + " turns left before move can be used.")
	else:
		var values = move.getModifiers(creature)
		values = values.map(func(obj):
			if creature:
				var val:int = obj.value if obj.value else -1
				var color:Color = obj.color if obj.color else Color.RED
			
				return ("[color=%s]%d[/color]") % [color.to_html(),val]
			else:
				return obj.calc
				
			)
		label.text = move.summary % values
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
