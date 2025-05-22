extends MoveButton

@onready var Receiver = $DragReceiver

#a move button that can be edited by dragging a move into it


func _ready():
	if Receiver:
		Receiver.drag_received.connect(addDraggedMove)
	pass;
	
func addDraggedMove(drag:Draggable):
	if drag and drag.get_parent() and drag.get_parent() is MoveButton:
		var moveButt := drag.get_parent() as MoveButton
		if moveButt and moveButt.getMove():
			setMove(drag.get_parent().getMove())
			drag.get_parent().queue_free()
	
