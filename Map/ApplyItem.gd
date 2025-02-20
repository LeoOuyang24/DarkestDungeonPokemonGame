extends PanelContainer

signal selected(c:Creature,m:int) #which creature/movebutton index was selected

@onready var summary := %Summary

@onready var submit := %Submit
@onready var label := %RichTextLabel
@onready var creatures := %Creatures2

var current:Creature = null:
	set(val):
		current = val
		if needCreature:
			submit.disabled = false
var currentMove:int = -1:
	set(val):
		currentMove = val
		if !needCreature:
			submit.disabled = false
var teamViewSlot := preload("res://Menus/TeamSlot.tscn")
var teamViewScript := preload("res://Menus/TeamViewSlot.gd")

var needCreature:bool = true #true if you need a creature selected, false if you need a move selected

# Called when the node enters the scene tree for the first time.
func _ready():
	var hbox = creatures
	var i := 0
	for creature in GameState.PlayerState.getTeam():
		var slot := creatures.get_children()[i]
		slot.setCreature(creature)	
		slot.pressed.connect(select.bind(slot.creature))
		i+=1;
	summary.Moves.move_selected.connect(selectMove)
	submit.disabled = true

func selectMove(_m,m:MoveButton):
	currentMove = summary.Moves.Moves.find(m)
	
func select(creature:Creature):
	current = creature;
	#if needCreature, disable move buttons
	#technically not what this 2nd parameter is made for but hey it works
	summary.setCurrentCreature(creature,!needCreature)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		finish()

func setText(str:String) -> void:
	label.set_text(str)

func _on_confirm_pressed():
	selected.emit(current,currentMove)
	pass # Replace with function body.
	
func finish():
	visible = false
	submit.disabled = true
