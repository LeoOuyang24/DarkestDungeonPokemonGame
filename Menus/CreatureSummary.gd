class_name CreatureSummary extends Control

var creature:Creature = null


@onready var Sprite = %CreatureStats.find_child("Sprite")
@onready var StatsWindow = %CreatureStats

@onready var LearnNewMove = %LearnNewMove
@onready var LevelUpButton = %LevelUp

@onready var Stats = [StatsWindow.find_child("Health"),StatsWindow.find_child("Attack"),StatsWindow.find_child("Speed")]
@onready var Name:RichTextLabel = %CreatureStats.find_child("Name")



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Stats:
		i.setMaxWidth(StatsWindow.size.x )

	setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))
	pass # Replace with function body.
	
#set the creature we are currently changing
func setCreature(creature:Creature) -> void:
	if creature:
		self.creature = creature
		Sprite.setCreature(creature)
		#Sprite.setSprite(creature.getSprite())

		#add moves to UI
		LearnNewMove.setMoves(creature)
		if LevelUpButton:
			LevelUpButton.setCreature(creature)
		#add stats to UI
		for i in range(Stats.size()):
			Stats[i].setCreature(creature,i)

			
		creature.level.leveled_up.connect(updateCreature)
			
		#add everything else to UI
		updateCreature()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BACKSLASH:
			creature.traits.addStatus(Small.new())
		if event.keycode == KEY_BACKSPACE:
			creature.traits.addStatus(Big.new())
	
func updateCreature() -> void:

	#LevelUpCost.set_text(str(getLevelUpCost()))
	#if we have the option of learning a new move, update
	var nextMove = creature.level.getNextLevelUpMove()
	if nextMove:
		LearnNewMove.setNewMove(nextMove)
	
	#update the label to reflect our new level
	Name.set_text(str(creature.getName()) + "\nLevel "+str(creature.getLevel()))
	Name.creature = creature

		
#update summary when hovering over the levelup button to see what the new stats will be
func onHover() -> void:		
	if creature:
		for stat in Stats:
			stat.setBonus(Stat.perLevelIncrease(creature.stats.getBaseStat(stat.stat)))
		
func offHover() -> void:
	if creature:
		for stat in Stats:
			stat.setBonus(0)
		
func _on_learn_new_move_new_move_confirmed(moves:Array):
	if creature:
		creature.level.moveConsidered()
		creature.setMoves(moves)
	pass # Replace with function body.


func _on_level_up_pressed():
	if creature:
		creature.levelUp()
		print(GameState.getDNA())
	pass # Replace with function body.
