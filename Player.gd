class_name Player extends Object

#stores player state

signal team_changed()
signal added_scan(creatureName:StringName)
#emitted when a move is added to inventory
signal added_move(move:Move)

const PLAYER_BASE_MAX_HEALTH:int = 100
const PLAYER_BASE_ATTACK:int = 50
const PLAYER_BASE_SPEED:int = 50
const MAX_TEAM_SIZE:int = 4

var player:Creature = null
var team:Array = [] #all friendly creatures, including the player and nulls
var teamSize:int = 0

#array of creatures we've scanned
#for now I guess just store the names and well load the jsons
#but probably need a better solution that doesn't reload every json all the time
#TODO
var scans:Array = []

var inventory:Array = [Chomp.new(),Bite.new()]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init() -> void:
	reset()
	
func addMove(move:Move):
	if move:
		inventory.push_back(move)
		added_move.emit(move)	

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
	team = []
	teamSize = 0
	for i in range(Battlefield.maxAllies):
		if i < creatures.size():
			team.push_back(creatures[i])
			if creatures[i]:
				teamSize += 1
				creatures[i].isFriendly = true
		else:
			team.push_back(null)
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
	#player = Creature.new("spritesheets/creatures/player",PLAYER_BASE_MAX_HEALTH,PLAYER_BASE_ATTACK,PLAYER_BASE_SPEED,"Player",5,[SwapPos.new(),Brutalize.new(),Hamstring.new(),GrantSpeed.new()])
	player = Creature.new(SpriteLoader.getSprite("spritesheets/creatures/player"),PLAYER_BASE_MAX_HEALTH,PLAYER_BASE_ATTACK,PLAYER_BASE_SPEED,"Player",1,[Shoot.new(),Scan.new(),SwapPos.new()])

	player.isPlayer = true	
#
	var ally1 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/giant.json")
	var ally2 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json")
	var ally3 = Banshee.new()
	var ally4 = CreatureLoader.loadJSON("res://Creatures/creatures_jsons/silent.json")
	#ally2.traits.addStatus(Spectral.new())
	updateTeam([player,ally2])

	#team[1].traits.addStatus(Spectral.new())
	#team[0].traits.addStatus(Big.new())
