class_name Game extends Node2D

@onready var Scenes = $Scenes
@onready var Map = $Scenes/Map
@onready var TeamView = $TeamView
@onready var FadeOut = $FadeOut

var showTeam = false
var curScene = null

static var PlayerState:Player = Player.new()

#used to track game state

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	swapToScene(Map)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#switch to scene, deleting the previous current scene if necessary

func swapToScene(scene:Node2D):

	Scenes.remove_child(curScene)
	Scenes.add_child(scene)
	curScene = scene

#same as swapToScene except we do the fadeout animation
func swapToSceneWithFade(scene:Node2D):
	FadeOut.play(true)
	await FadeOut.transition_finished	
	
	swapToScene(scene)
	
	FadeOut.play()
	await FadeOut.transition_finished

	
func _on_map_room_selected(roomInfo):
	var newScene = null
	match roomInfo.getRoomType():
		RoomInfo.ROOM_TYPES.BATTLE:
			newScene = load("res://Battle/BattleManager.tscn").instantiate()
			newScene.createBattle(PlayerState.getPlayer(),PlayerState.getTeam(),roomInfo.getEnemies())
		RoomInfo.ROOM_TYPES.WELL:
			var wellRoom = load("res://Map/Rooms/WellRoom.tscn").instantiate()
			newScene = wellRoom
			pass
		_:
			push_error("Game.gd: Somehow, RoomInfo ROOM_TYPE was not matched!")
	
	if newScene:
		newScene.room_finished.connect(room_finished)	
		swapToSceneWithFade(newScene)

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

func room_finished():
	swapToSceneWithFade(Map)


func _on_battle_manager_battle_finished(won:bool):
	if !won:
		PlayerState.reset()
		Map.reset()
	swapToScene(Map)
	pass # Replace with function body.
