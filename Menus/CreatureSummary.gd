extends Node2D

var creature:Creature = null

@onready var Moves:Array[MoveButton] = [$Window/Moves/Button,$Window/Moves/Button2,$Window/Moves/Button3,$Window/Moves/Button4] 

@onready var Health:StatBar = $Window/Stats/Control/Health
@onready var Attack:StatBar = $Window/Stats/Control/Attack
@onready var Speed:StatBar = $Window/Stats/Control/Speed

@onready var Name:RichTextLabel = $Window/Stats/Name

# Called when the node enters the scene tree for the first time.
func _ready():
	updateCreature(CreatureLoader.loadJSON("res://Creatures/creatures_jsons/chomper.json"))
	pass # Replace with function body.

func updateCreature(creature:Creature) -> void:
	self.creature = creature
	
	if creature:
		for i in range(Creature.maxMoves):
			Moves[i].setMove(creature.getMove(i))
			
		Health.growTo(creature.getMaxHealth())
		Attack.growTo(creature.getBaseAttack())
		Speed.growTo(creature.getBaseSpeed())
		
		updateText()
		
func updateText() -> void:
	if creature:
		Name.set_text(str(creature.getName()) + "\nLevel "+str(creature.getLevel()))
		
#update summary when hovering over the levelup button to see what the new stats will be
func onHover() -> void:		
	if creature:
		var stats = creature.getStatsAtLevel(creature.getLevel() + 1)
		Health.setBonus(stats.health - creature.getMaxHealth())
		Attack.setBonus(stats.attack - creature.getBaseAttack())
		Speed.setBonus(stats.speed - creature.getBaseSpeed())
		
func offHover() -> void:
	if creature:
		Health.setBonus(0)
		Attack.setBonus(0)
		Speed.setBonus(0)
		
func levelUp():
	creature.levelUp()
	updateCreature(creature)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
