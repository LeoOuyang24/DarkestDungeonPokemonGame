extends Control

@onready var MovesUI := %MovesUI
@onready var Accept := %Accept

var MoveButtonScene = preload("res://Battle/UI/MoveButton.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Creature.maxMoves:
		var move := MoveButtonScene.instantiate()
		move.setMove(null,null)
		MovesUI.add_child(move)
	pass # Replace with function body.

func loadMoves(creature:Creature):
	if creature:
		for i in range(creature.maxMoves):
			if i >= creature.moves.size():
				MovesUI.get_children()[i].setMove(null,creature)
			else:
				MovesUI.get_children()[i].setMove(creature.moves[i],creature)
			
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
