extends TextureButton

var move:Move = null:
	set(val):
		move = val
		visible = (creature != null and move != null)
		if move:
			set_texture_normal(move.icon)
			
var creature:Creature = null:
	set(val):
		creature = val
		if GameState.getBattle():
			move = GameState.getBattle().moveQueue.getMove(creature)
		visible = (creature != null and move != null)

func _ready():
	tooltip_text="No Move Selected!"
	if GameState.getBattle():
		GameState.getBattle().add_move_queue.connect(updateMove)
		GameState.getBattle().new_turn.connect(set.bind("move",null))

func _make_custom_tooltip(summary:String):
	return MoveButton.getMoveTooltip(move,creature)
	
func updateMove(record:Move.MoveRecord) -> void:
	if record.user == creature:
		move = record.move
	
 
