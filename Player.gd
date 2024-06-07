class_name Player extends Node

#stores player state

const PLAYER_BASE_MAX_HEALTH = 200

var player:Creature = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	reset()
	
func getPlayer():
	return player

#returns true if the player is dead
func isPlayerDead():
	return player && !player.isAlive();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#reset player state
func reset():
	player = Creature.create("spritesheets/creatures/player",PLAYER_BASE_MAX_HEALTH,"Player",[SwapPos.new()])
	player.isPlayer = true	
