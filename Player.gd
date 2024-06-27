class_name Player extends Node

#stores player state

const PLAYER_BASE_MAX_HEALTH:int = 20
const PLAYER_BASE_ATTACK:int = 5
const PLAYER_BASE_SPEED:int = 5

var player:Creature = null
var team:Array = []



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init() -> void:
	reset()
	
func getPlayer() -> Creature:
	return player

func getTeam() -> Array:
	return team

#returns true if the player is dead
func isPlayerDead():
	return player && !player.isAlive();

#reset player state
func reset() -> void:
	player = Creature.new("spritesheets/creatures/player",PLAYER_BASE_MAX_HEALTH,PLAYER_BASE_ATTACK,PLAYER_BASE_SPEED,"Player",5,[SwapPos.new()])
	player.isPlayer = true	
	
	var ally1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/beholder.json")
	var ally2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/silent.json")
	
	
	ally1.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	ally2.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	
	team = [ally1,ally2,CreatureLoader.loadJSON("res://Creatures/creatures_jsons/siren.json"),CreatureLoader.loadJSON("res://Creatures/creatures_jsons/dreemer.json") ]

