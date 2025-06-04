class_name CreateHorrorButton extends PanelContainer

@onready var button = %Button

#UI Element for CreateHorror
#confusingly, this is not a button, but a container that has a button in it


var disabled:bool = false:
	set(value):
		disabled = value
		modulate = Color(0.2,0.2,0.2,1) if disabled else Color.WHITE
		button.disabled = value
		if disabled:
			button.set_tooltip_text("This creature is already in your team!")
		else:
			button.set_tooltip_text("")

var creature:Creature = null:
	set(value):
		creature = value
		button.setSprite(creature.getSprite())
		button.setSize(Vector2(100,100))
		updateDisabled()

#update disabled based on whether or not the creature is already in the party
func updateDisabled():
	disabled = GameState.PlayerState.getTeam().reduce(func (accum:bool, creature2:Creature):
			return accum || (creature2 and creature2.getName() == creature.getName())
			,false)	
			
func _ready():
	GameState.PlayerState.team_changed.connect(updateDisabled)
