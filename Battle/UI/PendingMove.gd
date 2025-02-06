extends TextureButton

var move:Move = null
var creature:Creature = null

func _ready():
	tooltip_text="No Move Selected!"

func _make_custom_tooltip(summary:String):
	return MoveButton.getMoveTooltip(move,creature)
	
