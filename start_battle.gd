class_name Battlefield extends Node2D

#general battle logic

#current player creature we are choosing moves for
#null if we aren't showing player creature moves
var currentPlayerCreature = null;

const maxAllies = 4;
const maxEnemies = 4;

var allies = []
var enemies = []

var moveQueue = MoveQueue.new();

var sequencer = []; #list of sequence units

enum BATTLE_STATES {
	PLAYER_TURN,
	ENEMY_TURN
	}
	
var state = BATTLE_STATES.PLAYER_TURN;
var animeStart = -1; #the time we started with animations
# Called when the node enters the scene tree for the first time.

@onready var BattleUI = $BattleUI

func _init():
	allies.resize(maxAllies)
	allies.fill(null)
	
	enemies.resize(maxEnemies);
	enemies.fill(null)

func advanceState():
	setState((state + 1)%(BATTLE_STATES.size()));
	
func setBattleText(text:String):
	BattleUI.BattleLog.set_text(text)
	
func setState(state_):
	state = state_
	if (state == BATTLE_STATES.PLAYER_TURN):
		if BattleUI.BattleLog:
			setBattleText("What will you do??")
		else:
			push_error("BATTLE LOG NOT ADDED AS CHILD TO BATTLE")

func addCreature(creature:Creature, index:int, isAlly:bool):
	var row = null; #array of creatures, either the enemies or allies
	var max = 0;
	if isAlly:
		row = allies;
		max = maxAllies;
	else:
		row = enemies;
		max = maxEnemies;
	
	if index >= 0 && index < max && row[index] == null:
		row[index] = creature;
	var boolin = (1 if isAlly else 0)
	#set creature position in the battle field
	BattleUI.addCreature(creature,index,isAlly);
	
	#BattleUI.getCreaturePos(index,isAlly);

	
	add_child(creature);

	if (isAlly):	
		var sprite = creature.get_node("Sprite");
		if sprite:
			sprite.flip_h = true;

func _ready():
	setState(BATTLE_STATES.PLAYER_TURN)
	
	var player = Creature.create("dialga",100,"Player")

	player.setAttacks([Tackle.new(),HyperBeam.new(),NastyPlot.new()]);
	addCreature(player,0,true);
	
	addCreature(Creature.create("dialga",100,"Player"),1,true);
	
	var enemy = Creature.create("magikarp",100,"Enemy");
	enemy.setAttacks([Splash.new()])
	addCreature(enemy,0,false);
	
	var enemy2 = Creature.create("magikarp",100,"Enemy");
	enemy2.setAttacks([Tackle.new()])
	#enemy2.speed = 100;
	addCreature(enemy2,1,false);

	BattleUI.addAttacksToUI(player);
	#tween.tween_callback(allies[0].Sprite.queue_free)


	pass # Replace with function body.


#set a move's animation. If null, stop rendering the current animation
func setBattleSprite(sprite:SpriteFrames) -> void:
	if sprite == null:
		BattleUI.stopBattleSprite();
	else:
		BattleUI.setBattleSprite(sprite);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if (len(sequencer) > 0):
		if sequencer[len(sequencer)  - 1].run(delta,self): #if we are done with this unit ...
			sequencer.pop_back(); #...remove it
	else:
		if (state == BATTLE_STATES.ENEMY_TURN):
			for i in enemies:
				if i:
					moveQueue.insert(i)
			for i in moveQueue.data:	
				processMove(i,allies,Creature.AI(i,enemies,allies));
			state = BATTLE_STATES.PLAYER_TURN;
	pass
			
#add a move to the sequence
func processMove(user,targets,move):
	#var sequence = SequenceUnit.createMoveSequence(user,move,targets)
	var sequence = move.createMoveSequence(user,move,targets)
	#copy the array in reverse order, because popping from the back is easier than popping from the front
	for i in range(len(sequence) - 1, -1,-1):
		sequencer.append(sequence[i])
