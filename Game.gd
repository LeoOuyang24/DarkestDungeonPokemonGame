extends Node2D

@onready var Battle = $BattleManager
@onready var Map = $Map

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
	for i in get_children():
		i.set_process(i==scene)
		i.set_visible(i==scene)
		
	#Map.set_process(false)
	#Map.set_visible(false)
	#Battle.set_process(true)



func _on_map_room_selected(room):
	#Battle.test()
	swapToScene(Battle)
	
	var ally1 = Creature.create("spritesheets/creatures/chomper",100,"Chomper 1")
	var ally2 = Creature.create("spritesheets/creatures/chomper",100,"Chomper 2")
	
	
	ally2.speed = 11;
	
	ally1.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	ally2.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	
	Battle.createBattle(PlayerState.getPlayer(),[ally1,ally2],room.getRoomInfo().getEnemies())
	Battle.newTurn()
	pass # Replace with function body.


func _on_battle_manager_battle_finished(won:bool):
	if !won:
		PlayerState.reset()
		Map.reset()
	swapToScene(Map)
	pass # Replace with function body.
