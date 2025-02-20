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
		StatsWindow.setCreature(creature)
		#Sprite.setCreature(creature)
		#Sprite.setSprite(creature.getSprite())

		#add moves to UI
		if LearnNewMove:
			LearnNewMove.setMoves(creature)
			if LevelUpButton:
				LevelUpButton.setCreature(creature)
	

			
		creature.level.leveled_up.connect(updateCreature)
		creature.stats.stat_changed.connect(func(_a,_b):
				updateCreature())
		
		var bigBoosts = get_tree().get_nodes_in_group("BigBoosts")
		for i:int in bigBoosts.size():
			var node := bigBoosts[i] as TextureButton
			node.mouse_entered.connect(Stats[i].setBonus.bind(Stat.BIG_BOOST_AMOUNT,Color.BLUE))
			node.mouse_exited.connect(Stats[i].setBonus.bind(0))
			node.pressed.connect(addBigBoost.bind(Stats[i].stat))
		#add everything else to UI
		updateCreature()

func addBigBoost(stat:CreatureStats.STATS) -> void:
	if creature:
		creature.addBigBoost(stat)

func updateCreature() -> void:

	#LevelUpCost.set_text(str(getLevelUpCost()))
	#if we have the option of learning a new move, update
	var nextMove = creature.level.getNextLevelUpMove()
	if nextMove:
		LearnNewMove.setNewMove(nextMove)
	
	#update the label to reflect our new level
	Name.set_text(str(creature.getName()) + "\nLevel "+str(creature.getLevel()))
	Name.creature = creature

	var bigBoosts = get_tree().get_nodes_in_group("BigBoosts")

	for i:TextureButton in bigBoosts:
		i.visible = (creature.level.getPendingBigBoosts() > 0)

	
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
	pass # Replace with function body.
