class_name Game extends Node

@onready var Scenes := %Scenes
@onready var Map := %Map
@onready var TeamView := %TeamView
@onready var FadeOut := %FadeOut
@onready var NewScan := %"NewScan!"
@onready var BloodAnimation := %HurtAnimation
@onready var GameOver := %GameOver
@onready var GameOverButton := %GameOver/Button
@onready var DNACounter := %DNACounter/Counter
@onready var Tutorial := %TutorialState

static var GameCamera:GlobalCamera = null

signal swapped_to_room(room:RoomBase)


var curScene = null
var showTeam := false

#static var GameState:GlobalGameState = GlobalGameState.new()
#used to track game state

# Called when the node enters the scene tree for the first time.
func _ready():		
	GameCamera = $Camera
	GameState.DNA_changed.connect(func(amount):
		DNACounter.set_text(str(GameState.getDNA()))
		)
	GameState.battle_started.connect(showTeamView.bind(false))
	GameState.PlayerState.added_scan.connect(func (creatureName:StringName):
			NewScan.setCreature(creatureName)
			var tween = NewScan.create_tween()
			tween.tween_property(NewScan,"position",Vector2(NewScan.position.x,0),1);
			tween.tween_property(NewScan,"position",Vector2(NewScan.position.x,-NewScan.get_size().y),1).set_delay(2);
			)
	
	GameState.PlayerState.getPlayer().stats.getStatObj(CreatureStats.STATS.HEALTH).stat_changed.connect(func(amount:int,val:int):
		if amount < 0:
			BloodAnimation.play("hurt")
		)
		
	GameState.game_lost.connect(loseGame)
	
	DNACounter.set_text(str(GameState.getDNA()))
	swapToScene(Map)
	if (GameState.isTutorial):
		Tutorial.run(self)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#switch to scene, deleting the previous current scene if necessary
func swapToScene(scene:RoomBase):
	Scenes.remove_child(curScene)
	Scenes.add_child(scene)
	curScene = scene
	swapped_to_room.emit(scene)
	if scene is BattleManager:
		GameState.setBattle(scene.BattleSim)
	#if DebugState.isDebugging():
	%DebugState.swapToRoom(scene)


#same as swapToScene except we do the fadeout animation
func swapToSceneWithFade(scene:RoomBase):
	FadeOut.play()
	await FadeOut.transition_finished	
	
	swapToScene(scene)
	
	FadeOut.play(true)
	await FadeOut.transition_finished
	#scene.onSelect()
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E and !GameState.getBattle():
			showTeamView(!showTeam)

#turn TeamView on/off		
func showTeamView(val:bool):
	var tween = create_tween();
	showTeam = val
	#how long it takes for the menu to pull up
	var time = 0.25
	if showTeam:
		TeamView.Summary.setCreature(GameState.PlayerState.getPlayer())
		TeamView.updateTeamSlots(GameState.PlayerState.getTeam())
		tween.tween_property(TeamView, "position",Vector2(TeamView.position.x,0.1*get_viewport().get_visible_rect().size.y),time)
	else:
		tween.tween_property(TeamView, "position",Vector2(TeamView.position.x,get_viewport().get_visible_rect().size.y),time)

	
func _on_map_room_selected(roomInfo):
	var newScene:RoomBase = null
	match roomInfo:
		Room.ROOM_TYPES.BATTLE:
			newScene = load("res://Battle/BattleManager.tscn").instantiate()
			#var enemies = [CreatureLoader.loadJSON("silent.json"),CreatureLoader.loadJSON("dreemer.json"),CreatureLoader.loadJSON("beholder.json"),CreatureLoader.loadJSON("beholder.json")]
			var enemies = []
			var size = randi()%(Battlefield.maxEnemies - 1) + 1
			for i in range(size):
				enemies.push_back(CreatureLoader.getRandCreature(["chomper","giant","masked","princess","siren","silent"]))

			#newScene.createBattle(enemies)
			Bosses.boss1(newScene)
		Room.ROOM_TYPES.WELL:
			var wellRoom = load("res://Map/Rooms/WellRoom.tscn").instantiate()
			newScene = wellRoom
		Room.ROOM_TYPES.SHOP:
			var shopRoom = load("res://Map/Rooms/ShopRoom/ShopRoom.tscn").instantiate()
			newScene = shopRoom
		Room.ROOM_TYPES.COMBINE_MOVES:
			var labRoom = load("res://Map/Rooms/CombineMoveRoom/LabMovesRoom.tscn").instantiate()
			newScene = labRoom
		_:
			push_error("Game.gd: Somehow, RoomInfo ROOM_TYPE was not matched!")
	if newScene:
		newScene.room_finished.connect(room_finished)	
		await swapToSceneWithFade(newScene)

func room_finished():
	swapToSceneWithFade(Map)
	Map.updateRooms()
	if GameState.getBattle():
		GameState.setBattle(null)

func loseGame():
	GameOver.visible = true
	await GameOverButton.pressed;
	get_tree().change_scene_to_file("res://Menus/MainMenu.tscn")
	GameState.reset()
	GameOver.visible = false
#func battle_finished(won:bool):
	#if !won:
		#get_tree().change_scene_to_file("res://Menus/MainMenu.tscn")
		#GameState.PlayerState.reset()
	#else:
		#room_finished()
		
