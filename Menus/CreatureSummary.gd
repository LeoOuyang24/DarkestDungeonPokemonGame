class_name CreatureSummary extends BaseCreatureSummary

#@onready var Sprite = %CreatureStats.find_child("Sprite")

@onready var LearnNewMove = %LearnNewMove
@onready var LevelUpButton = %LevelUp
#@onready var Name:RichTextLabel = %CreatureStats.find_child("Name")

#signal for when we swap to a different creature
#CAN BE NULL
signal swapped_current(current:Creature)

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	Stats.forEachStat(func(s:StatBar):
		s.setMaxWidth(Stats.size.x)
		)
	#setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))
	pass # Replace with function body.
	#
##set the creature we are currently changing
#"changing" is true if we can modify this creature (level it up, for example)
func setCreature(creature:Creature) -> void:
	setCurrentCreature(creature,true)
	if creature:
		##add moves to UI
		LearnNewMove.setMoves(creature)
		LevelUpButton.disabled = false
		LevelUpButton.setCreature(creature)
		creature.level.leveled_up.connect(updateCreature)
		creature.stats.stat_changed.connect(updateCreature.unbind(2))
		updateCreature()
	swapped_current.emit(creature)

func _process(delta):
	LevelUpButton.disabled = !creature or \
	creature not in GameState.PlayerState.getTeam() or\
	LevelUpButton.cost > GameState.getDNA()

func addBigBoost(stat:CreatureStats.STATS) -> void:
	if creature:
		creature.addBigBoost(stat)

#stuff that has to happen any time the creature gets updated
func updateCreature() -> void:
	#if we have the option of learning a new move, update
	var nextMove = creature.level.getNextLevelUpMove()
	LearnNewMove.setNewMove(nextMove)
	
	%CreatureStats.setLabel(creature)

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
