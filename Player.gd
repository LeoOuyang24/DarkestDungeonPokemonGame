class_name Player extends Node

#stores player state

signal team_changed()

const PLAYER_BASE_MAX_HEALTH:int = 20
const PLAYER_BASE_ATTACK:int = 5
const PLAYER_BASE_SPEED:int = 5
const MAX_TEAM_SIZE:int = 4

var player:Creature = null
var team:Array = []

#array of creatures we've scanned
#for now I guess just store the names and well load the jsons
#but probably need a better solution that doesn't reload every json all the time
#TODO
var scans:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init() -> void:
	reset()
	
func getPlayer() -> Creature:
	return player

func getTeam() -> Array:
	return team
	
func addCreatureToTeam(creature:Creature) -> void:
	if team.size() < MAX_TEAM_SIZE:
		team.push_back(creature)
		team_changed.emit()

#returns true if the player is dead
func isPlayerDead():
	return player && !player.isAlive();

func getScans() -> Array:
	return scans

func addScan(creatureName):
	scans.push_back(creatureName)

#reset player state
func reset() -> void:
	player = Creature.new("spritesheets/creatures/player",PLAYER_BASE_MAX_HEALTH,PLAYER_BASE_ATTACK,PLAYER_BASE_SPEED,"Player",5,[SwapPos.new(),Scan.new(),Hamstring.new(),GrantSpeed.new()])
	player.isPlayer = true	
	
	var ally1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/beholder.json")
	var ally2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/silent.json")
	
	
	#ally1.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	#ally2.setMoves([Bite.new(),Slash.new(),Grow.new()]);
	
	team = [CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"),CreatureLoader.loadJSON("res://Creatures/creatures_jsons/silent.json") ]
