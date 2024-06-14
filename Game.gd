extends Node2D

@onready var Scenes = $Scenes
@onready var Battle = $Scenes/BattleManager
@onready var Map = $Scenes/Map
@onready var TeamView = $TeamView

var showTeam = false
var PlayerState:Player = Player.new()

#used to track game state

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	swapToScene(Map)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func swapToScene(scene:Node2D):
	for i in Scenes.get_children():
		i.set_process(i==scene)
		i.set_visible(i==scene)



func _on_map_room_selected(room):
	swapToScene(Battle)
	
	Battle.createBattle(PlayerState.getPlayer(),PlayerState.getTeam(),room.getRoomInfo().getEnemies())
	Battle.newTurn()
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			showTeamView()

#turn TeamView on/off		
func showTeamView():
	var tween = create_tween();
	showTeam = !showTeam
	#how long it takes for the menu to pull up
	var time = 0.5
	if showTeam:
		TeamView.updateTeamSlots(PlayerState.getPlayer(),PlayerState.getTeam())
		tween.tween_property(TeamView, "position",Vector2(TeamView.position.x,0),0.25)
	else:
		tween.tween_property(TeamView, "position",Vector2(TeamView.position.x,get_viewport().get_visible_rect().size.y),0.25)

func _on_battle_manager_battle_finished(won:bool):
	if !won:
		PlayerState.reset()
		Map.reset()
	swapToScene(Map)
	pass # Replace with function body.
