class_name Player extends Node

#stores player state

signal team_changed()
signal added_scan(creatureName:StringName)

const PLAYER_BASE_MAX_HEALTH:int = 20
const PLAYER_BASE_ATTACK:int = 5
const PLAYER_BASE_SPEED:int = 5
const MAX_TEAM_SIZE:int = 4

var player:Creature = null
var team:Array = [] #all friendly creatures, including the player and nulls
var teamSize:int = 0

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
	if teamSize < MAX_TEAM_SIZE and creature:
		for i in range(team.size()): #find the first empty spot and insert
			if !team[i]:
				team[i] = creature
				break
		team_changed.emit()
		teamSize +=1

func removeCreatureFromTeam(creature:Creature) -> void:
	if creature in team:
		team.erase(creature)
		team_changed.emit()
		teamSize -= 1


func updateTeam(creatures:Array) -> void:
	team = creatures
	for i:Creature in team:
		if i:
			i.isFriendly = true
	teamSize = team.reduce(func(n:int,creature:Creature):
		return n + int(creature != null)
		,0)
	team_changed.emit()

#returns true if the player is dead
func isPlayerDead():
	return player && !player.isAlive();

func getScans() -> Array:
	return scans

func addScan(creatureName:StringName):
	if scans.find(creatureName) == -1:
		scans.push_back(creatureName)
		added_scan.emit(creatureName)

#reset player state
func reset() -> void:
	player = Creature.new("spritesheets/creatures/player",PLAYER_BASE_MAX_HEALTH,PLAYER_BASE_ATTACK,PLAYER_BASE_SPEED,"Player",5,[SwapPos.new(),Slam.new(),Hamstring.new(),GrantSpeed.new()])
	player.isPlayer = true	
#
	var ally1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/giant.json")
	var ally2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json")
	ally1.traits.addStatus(Spectral.new())
	updateTeam([player,ally2])

	#team[1].traits.addStatus(Spectral.new())
	#team[0].traits.addStatus(Big.new())
