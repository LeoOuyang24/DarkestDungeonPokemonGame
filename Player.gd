class_name Player extends Node

#stores player state

const PLAYER_BASE_MAX_HEALTH = 200

var player:Creature = null
var team:Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	reset()
	
func getPlayer():
	return player

func getTeam():
	return team

#returns true if the player is dead
func isPlayerDead():
	return player && !player.isAlive();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#reset player state
func reset():
	player = CreatureLoader.create("spritesheets/creatures/player",PLAYER_BASE_MAX_HEALTH,"Player",[SwapPos.new()])
	player.isPlayer = true	
	
	var ally1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/beholder.json")
	var ally2 = CreatureLoader.create("spritesheets/creatures/chomper",100,"Chomper 2")
	
	
	ally2.speed = 11;
	
	ally1.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	ally2.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	
	team = [ally1,ally2,CreatureLoader.loadJSON("res://Creatures/creatures_jsons/siren.json"),CreatureLoader.loadJSON("res://Creatures/creatures_jsons/dreemer.json") ]
	team[1].setHealth(0)	
