class_name Game extends Node2D

@onready var Scenes = $Scenes
@onready var Map = $Scenes/Map
@onready var TeamView = $TeamView
@onready var FadeOut = $FadeOut
@onready var DNACounter = $DNACounter/Label

var curScene = null
var showTeam = false

#static var GameState:GlobalGameState = GlobalGameState.new()
#used to track game state

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.DNA_changed.connect(func(amount):
		DNACounter.set_text(str(GameState.getDNA()))
		)
	GameState.initiate()
	Map.updateRooms() #this is called in two places, one here and one when the battle ends. It really should be added to a single function called "SwaptoMap" or something
	swapToScene(Map)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#switch to scene, deleting the previous current scene if necessary
func swapToScene(scene):
	Scenes.remove_child(curScene)
	Scenes.add_child(scene)
	curScene = scene

#same as swapToScene except we do the fadeout animation
func swapToSceneWithFade(scene):
	FadeOut.play()
	await FadeOut.transition_finished	
	
	swapToScene(scene)
	
	FadeOut.play(true)
	await FadeOut.transition_finished
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			showTeamView()

#turn TeamView on/off		
func showTeamView():
	var tween = create_tween();
	showTeam = !showTeam
	#how long it takes for the menu to pull up
	var time = 0.25
	if showTeam:
		TeamView.updateTeamSlots(GameState.PlayerState.getPlayer(),GameState.PlayerState.getTeam())
		tween.tween_property(TeamView, "position",Vector2(TeamView.position.x,0.1*get_viewport().get_visible_rect().size.y),time)
	else:
		tween.tween_property(TeamView, "position",Vector2(TeamView.position.x,get_viewport().get_visible_rect().size.y),time)

	
func _on_map_room_selected(roomInfo):
	var newScene = null
	match roomInfo:
		Room.ROOM_TYPES.BATTLE:
			newScene = load("res://Battle/BattleManager.tscn").instantiate()
			var enemies = [CreatureLoader.loadJSON("silent.json"),CreatureLoader.loadJSON("siren.json"),CreatureLoader.loadJSON("beholder.json")]
			#var size = randi()%(Battlefield.maxEnemies - 1) + 1
			#for i in range(size):
				#enemies.push_back(CreatureLoader.getRandCreature())
			newScene.createBattle(GameState.PlayerState.getPlayer(),GameState.PlayerState.getTeam(),enemies)
			GameState.setInBattle(true)
			newScene.room_finished.connect(battle_finished)
		Room.ROOM_TYPES.WELL:
			var wellRoom = load("res://Map/Rooms/WellRoom.tscn").instantiate()
			newScene = wellRoom
			newScene.room_finished.connect(room_finished)	
		_:
			push_error("Game.gd: Somehow, RoomInfo ROOM_TYPE was not matched!")
	if newScene:
		await swapToSceneWithFade(newScene)

func room_finished():
	swapToSceneWithFade(Map)
	Map.updateRooms()
	if GameState.getInBattle():
		GameState.setInBattle(false)


func battle_finished(won:bool):
	if !won:
		get_tree().change_scene_to_file("res://Menus/MainMenu.tscn")
	else:
		room_finished()
