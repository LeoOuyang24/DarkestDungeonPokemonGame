extends Node2D

var creature:Creature = null


@onready var Sprite = $Window/Stats/Anime
@onready var Stats = [$Window/Stats/Control/Health,$Window/Stats/Control/Attack,$Window/Stats/Control/Speed]
@onready var Health:StatBar = $Window/Stats/Control/Health
@onready var Attack:StatBar = $Window/Stats/Control/Attack
@onready var Speed:StatBar = $Window/Stats/Control/Speed

@onready var LearnNewMove = $Window/LearnNewMove

@onready var LevelUpButton:Button = $Window/LevelUp
@onready var LevelUpCost:RichTextLabel = $Window/LevelUp/Cost
@onready var Name:RichTextLabel = $Window/Stats/Name


# Called when the node enters the scene tree for the first time.
func _ready():
	var statRect = get_node("Window/Stats")
	
	Health.setMaxWidth(statRect.global_position.x + statRect.size.x - Health.Bar.global_position.x)
	Attack.setMaxWidth(statRect.global_position.x + statRect.size.x - Attack.Bar.global_position.x)
	Speed.setMaxWidth(statRect.global_position.x + statRect.size.x - Speed.Bar.global_position.x)
	
	#setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/beholder.json"))
	pass # Replace with function body.
	
#set the creature we are currently changing
func setCreature(creature:Creature) -> void:
	self.creature = creature
	Sprite.setSprite(creature.getSprite())
	if creature:
		#add moves to UI
		LearnNewMove.setMoves(creature)
		
		#add stats to UI
		for i in range(Stats.size()):
			Stats[i].setCreature(creature,i)
			
		#add everything else to UI
		updateCreature()


	
func updateCreature() -> void:
#	update the level up cost
	LevelUpCost.set_text(str(getLevelUpCost()))	
	if getLevelUpCost() > Game.GameState.getDNA():
		LevelUpButton.disabled = true
	else:
		LevelUpButton.disabled = false
	
	#if we have the option of learning a new move, update
	var nextMove = creature.getNextLevelUpMove()
	if nextMove:
		LearnNewMove.setNewMove(nextMove)
	
	#update the label to reflect our new level
	Name.set_text(str(creature.getName()) + "\nLevel "+str(creature.getLevel()))

		
#update summary when hovering over the levelup button to see what the new stats will be
func onHover() -> void:		
	if creature:
		Health.setBonus(creature.getPerLevelAmount(Creature.STATS.HEALTH))
		Attack.setBonus(creature.getPerLevelAmount(Creature.STATS.ATTACK))
		Speed.setBonus(creature.getPerLevelAmount(Creature.STATS.SPEED))
		
func offHover() -> void:
	if creature:
		Health.setBonus(0)
		Attack.setBonus(0)
		Speed.setBonus(0)
		
#how much dna it takes to level up
func getLevelUpCost() -> int:
	return creature.getLevel() if creature else 0
		
func levelUp():
	if creature:
		Game.GameState.setDNA(Game.GameState.getDNA() - getLevelUpCost())
		creature.levelUp()
		updateCreature()
	pass


func _on_learn_new_move_new_move_confirmed(moves:Array):
	if creature:
		creature.popNextLevelUpMove()
		creature.setMoves(moves)
	pass # Replace with function body.
