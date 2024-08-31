extends ColorRect

var creature:Creature = null


@onready var Sprite = $Stats/Anime
@onready var Stats = [$Stats/Control/Health,$Stats/Control/Attack,$Stats/Control/Speed]
@onready var Health:StatBar = $Stats/Control/Health
@onready var Attack:StatBar = $Stats/Control/Attack
@onready var Speed:StatBar = $Stats/Control/Speed

@onready var LearnNewMove = $LearnNewMove

@onready var LevelUpButton:Button = $LevelUp
@onready var Name:RichTextLabel = $Stats/Name



# Called when the node enters the scene tree for the first time.
func _ready():
	var statRect = get_node("Stats")
	
	Health.setMaxWidth(statRect.global_position.x + statRect.size.x - Health.Bar.global_position.x)
	Attack.setMaxWidth(statRect.global_position.x + statRect.size.x - Attack.Bar.global_position.x)
	Speed.setMaxWidth(statRect.global_position.x + statRect.size.x - Speed.Bar.global_position.x)

	setCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))

	pass # Replace with function body.
	
#set the creature we are currently changing
func setCreature(creature:Creature) -> void:
	self.creature = creature
	Sprite.setSprite(creature.getSprite())
	if creature:
		#add moves to UI
		LearnNewMove.setMoves(creature)
		LevelUpButton.setCreature(creature)
		#add stats to UI
		for i in range(Stats.size()):
			Stats[i].setCreature(creature,i)
			
		creature.level.leveled_up.connect(updateCreature)
			
		#add everything else to UI
		updateCreature()


	
func updateCreature() -> void:

	#LevelUpCost.set_text(str(getLevelUpCost()))
	#if we have the option of learning a new move, update
	var nextMove = creature.level.getNextLevelUpMove()
	if nextMove:
		LearnNewMove.setNewMove(nextMove)
	
	#update the label to reflect our new level
	Name.set_text(str(creature.getName()) + "\nLevel "+str(creature.getLevel()))

		
#update summary when hovering over the levelup button to see what the new stats will be
func onHover() -> void:		
	if creature:
		Health.setBonus(Stat.perLevelIncrease(creature.stats.getBaseStat(CreatureStats.STATS.HEALTH)))
		Attack.setBonus(Stat.perLevelIncrease(creature.stats.getBaseStat(CreatureStats.STATS.ATTACK)))
		Speed.setBonus(Stat.perLevelIncrease(creature.stats.getBaseStat(CreatureStats.STATS.SPEED)))
		
func offHover() -> void:
	if creature:
		Health.setBonus(0)
		Attack.setBonus(0)
		Speed.setBonus(0)
		
func _on_learn_new_move_new_move_confirmed(moves:Array):
	if creature:
		creature.popNextLevelUpMove()
		creature.setMoves(moves)
	pass # Replace with function body.
