extends PanelContainer

@onready var Moves := %Moves

signal move_learned(move:MoveButton)

var moveButtonScene = preload("res://Battle/UI/MoveButton.tscn")

func _ready():
	GameState.PlayerState.added_move.connect(loadMoves.unbind(1))
	loadMoves()

func clear():
	for i in Moves.get_children():
		Moves.remove_child(i)
		i.queue_free()

func loadMoves():
	clear()
	for i in GameState.PlayerState.inventory:
		var move:MoveButton = moveButtonScene.instantiate()
		move.setMove(i)
		Moves.add_child(move)
		move.move_selected.connect(move_learned.emit.bind(move).unbind(1))

func _on_creature_summary_swapped_current(creature: Creature) -> void:
	if creature:
		for i:MoveButton in Moves.get_children():
			#disable moves this creature already knows
			#or all moves if this creature is not in our team
			i.set_disabled(creature not in GameState.PlayerState.getTeam() or creature.moves.find_custom(func(slot:MoveSlot):
				return slot and i and slot.getMove() and \
				slot.getMove().getMoveName() == i.getMove().getMoveName()
				) != -1)
	pass # Replace with function body.
