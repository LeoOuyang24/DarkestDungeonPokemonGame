extends ScrollContainer

@onready var List = %List

var scene:PackedScene = load("res://Battle/UI/HistoryUnit.tscn")

func addMove(record:Move.MoveRecord) -> void:
	if record:
		var child = scene.instantiate();
		child.creature = record.user
		child.move = record.move
		List.add_child(child)
		List.move_child(child,0)
