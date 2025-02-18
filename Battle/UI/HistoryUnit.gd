extends PendingMove

#a control to be added to MoveHistory, representing a move that has been done
#for now, all this does is prevent PendingMove from making a bunch of connections
#in the future, this should also return a different tooltip, showcasing which user used what move

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tooltip_text="a"

	pass # Replace with function body.
	
func _make_custom_tooltip(summary:String):
	return MoveButton.getMoveTooltip(move,creature)
