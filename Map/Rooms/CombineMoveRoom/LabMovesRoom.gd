extends EventRoom

@onready var TeamView := %TeamView
@onready var MergeInto := %Green
@onready var MergeFrom := %Red
@onready var Result := %Result
@onready var Moves := %MovesUI
@onready var WhiteOut := %WhiteOut
@onready var Active := %Active #ui elements that are only active pre-merge

var active:bool = true #true if merge hasn't happened yet
var curTube:AnimatedButton = null #selected tube
var first:Creature = null
var other:Creature = null
# Called when the node enters the scene tree for the first time.
func _ready():
	onSelect()
	MergeInto.pressed.connect(loadTeam.bind(MergeInto))
	MergeFrom.pressed.connect(loadTeam.bind(MergeFrom))
	for i in GameState.PlayerState.getTeam():
		if i:
			var teamSlot := AnimatedButton.new();
			teamSlot.ignore_texture_size = true
			teamSlot.custom_minimum_size = Vector2(100,100)
			teamSlot.setSprite(i.getSprite())
			teamSlot.pressed.connect(loadCreatureIntoTube.bind(i))
			#teamSlot.setSprite(load("res://sprites/spritesheets/creatures/beholder.tres"))
			TeamView.add_child(teamSlot)

func loadCreatureIntoTube(creature:Creature):
	if curTube && creature:
		curTube.setSprite(creature.getSprite())
		if curTube == MergeInto:
			first = creature
		else:
			other = creature
	setResult()
		
		
func setResult():
	if first and other:
		Result.setSprite(first.getSprite())
		Moves.loadMoves(other)

func loadTeam(button:AnimatedButton) -> void:
	if active && button:
		curTube = button
		TeamView.global_position.y = button.global_position.y
		TeamView.global_position.x = button.global_position.x + button.get_rect().size.x;
		TeamView.visible = true;


func _unhandled_input(event):
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		TeamView.visible = false

func onSelect() -> void:
	await playIntro("Two tubes stand before you")


func _on_accept_pressed():
	if first and other:
		first.setMoves(other.moves)
		GameState.PlayerState.removeCreatureFromTeam(other)
		Background.set_texture(load("res://sprites/map/lab_empty.png"))
		Active.visible = false
		var tween = create_tween()
		WhiteOut.color.a = 1
		tween.tween_property(WhiteOut,"color",Color(1,1,1,0),0.5);
		await tween.finished
		Menu.setMessage("You gather the abomination you created")
	
		#set_texture(load("res://sprites/map/lab_empty.png"))
