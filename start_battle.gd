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
	PLAYER_WAIT,
	ENEMY_TURN,
	BATTLE
	}
	
@export var state = BATTLE_STATES.PLAYER_TURN;
var animeStart = -1; #the time we started with animations
# Called when the node enters the scene tree for the first time.

@onready var BattleUI = $BattleUI

func _init():
	allies.resize(maxAllies)
	allies.fill(null)
	
	enemies.resize(maxEnemies);
	enemies.fill(null)
	
func setBattleText(text:String):
	BattleUI.BattleLog.set_text(text)
	
func setState(state_):
	state = state_
	#print_debug(sequencer)
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

func removeCreature(creature:Creature):
	var creatureType = creature.creatureName
	print(creatureType)
	if(creatureType == "Enemy"):
		print("Removing creature:", creatureType)
		enemies.erase(creature)
	elif(creatureType == "Player"):
		allies.erase(creature)
		print("Player removed")

func _ready():
	
	var player = Creature.create("dialga",100,"Player")

	player.setAttacks([Tackle.new(),HyperBeam.new(),NastyPlot.new()]);
	addCreature(player,0,true);
	
	#addCreature(Creature.create("dialga",100,"Player"),1,true);
	
	var enemy = Creature.create("magikarp",100,"Enemy");
	enemy.setAttacks([Splash.new()])
	addCreature(enemy,0,false);
	
	var enemy2 = Creature.create("magikarp",100,"Enemy");
	enemy2.setAttacks([Tackle.new()])
	enemy2.speed = 100;
	addCreature(enemy2,1,false);

	moveQueue.data.push_back(player)
	moveQueue.data.push_back(enemy)
	moveQueue.data.push_back(enemy2)
	setState(BATTLE_STATES.BATTLE)
	pass


#set a move's animation. If null, stop rendering the current animation
func setBattleSprite(sprite:SpriteFrames) -> void:
	if sprite == null:
		BattleUI.stopBattleSprite();
	else:
		BattleUI.setBattleSprite(sprite);

# Called every frame. 'delta' is the elapsed time since the previous frame.
var _statedebugstr = 'startbattle state: %s\nbattleui state: %s'
func _process(delta):
	if $BattleUI/DebugStartBattleState:
		$BattleUI/DebugStartBattleState.set_text(
			 _statedebugstr % [BATTLE_STATES.keys()[state], BattleUI.States.keys()[BattleUI.state]]
		);
	if (state == BATTLE_STATES.BATTLE):
		# If sequencer's full there's still pending animations(?)
		if sequencer.size() > 0:
			if sequencer[len(sequencer)  - 1].run(delta,self): #if we are done with this unit ...
				sequencer.pop_back(); #...remove it
			for i in allies.size():
				if(allies[i] == null):
					break
				elif(allies[i].getHealth() == 0):
					removeCreature(allies[i])
			for i in enemies.size():
				if(enemies[i] == null):
					break
				elif(enemies[i].getHealth() == 0):
					removeCreature(enemies[i])		
		else:
			print_debug("anim sequencer empty, get next unit")
			var next_creature = moveQueue.data.front();
			if (next_creature.creatureName == "Player"):
				print("transition to player_turn");
				setState(BATTLE_STATES.PLAYER_TURN);
			else:
				print("transition to enemy_turn");
				setState(BATTLE_STATES.ENEMY_TURN);
	elif ((state == BATTLE_STATES.ENEMY_TURN || state == BATTLE_STATES.PLAYER_TURN)):
		# On player move:
		# add attacks to UI and set BattleUI to move selection state.
		# Register signal handler for the end of the targeting process, which will handle creature damage and requeueing the current creature.
		# Meanwhile, set state to PLAYER_WAIT so that the battle doesn't advance without player input.
		var cur_creature = moveQueue.data.pop_front();
		if (cur_creature.creatureName == "Player"):
			BattleUI.addAttacksToUI(cur_creature);
			BattleUI.changeState(BattleUI.States.SELECTING_MOVE)
			# Register signal handler for the end of targeting process,
			# which handles creature damage and
			BattleUI.targets_selected.connect(func (move,targets):
				setState(BATTLE_STATES.BATTLE)
				processMove(cur_creature,targets,move);
				moveQueue.data.push_back(cur_creature);
			);
			setState(BATTLE_STATES.PLAYER_WAIT);
		# On enemy move:
		# use CreatureAI to determine which move to make, execute move, then requeue at back.
		elif (cur_creature.creatureName == "Enemy"):
			#TODO should probably add signal to enemy, to mimic callback after player input
			processMove(cur_creature,allies,Creature.AI(cur_creature,enemies,allies));
			setState(BATTLE_STATES.BATTLE)
			moveQueue.data.push_back(cur_creature);
		elif (state == BATTLE_STATES.PLAYER_WAIT):
			# Don't do anything if player hasn't completed move selection in BattleUI
			pass


#add a move to the sequence
func processMove(user,targets,move):
	#var sequence = SequenceUnit.createMoveSequence(user,move,targets)
	var sequence = move.createMoveSequence(user,move,targets)
	#copy the array in reverse order, because popping from the back is easier than popping from the front
	for i in range(len(sequence) - 1, -1,-1):
		sequencer.append(sequence[i])
