extends ColorRect

signal done #emitted when done
signal selected(c:Creature) #which creature was selected
signal selected_move(m:Move) # which move was selected

@onready var summary := %Summary

@onready var submit := %Submit
@onready var label := %RichTextLabel
@onready var creatures := %Creatures2

var current:Creature = null;
var currentMove:Move = null;
var teamViewSlot := preload("res://Menus/TeamSlot.tscn")
var teamViewScript := preload("res://Menus/TeamViewSlot.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var hbox = creatures
	var i := 0
	for creature in GameState.PlayerState.getTeam():
		#var slot := teamViewSlot.instantiate();

		#hbox.add_child(slot);
		var slot := creatures.get_children()[i]
		slot.setCreature(creature)	
		slot.pressed.connect(select.bind(slot.creature))
		i+=1;
	
	for move in summary.Moves:
		move.pressed.connect(selectMove.bind(move))

func selectMove(m:MoveButton):
	currentMove = m.getMove();
	
func select(creature:Creature):
	current = creature;
	summary.setCreature(creature)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		done.emit()

func setText(str:String) -> void:
	label.set_text(str)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_confirm_pressed():
	selected.emit(current)
	selected_move.emit(currentMove);
	pass # Replace with function body.
	
	
func _on_cancel_pressed():
	done.emit();
	pass # Replace with function body.
