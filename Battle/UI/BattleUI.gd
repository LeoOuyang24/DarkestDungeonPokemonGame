class_name BattleUI extends Node2D

@onready var AllyRow = $AllyRow 
@onready var EnemyRow = $EnemyRow 
@onready var BattleSprite = $BattleSprite 
@onready var BattleSpriteRect = $BattleSpriteRect
@onready var BattleLog = $BattleLog
@onready var EndScreen = $EndScreen
@onready var TurnQueue = $TurnQueue

@onready var Moves = [$Moves/Button, $Moves/Button2, $Moves/Button3, $Moves/Button4, $Moves/PassButton]

#signal for when targets have been selected
signal target_selected(target)

#signal for when a move has been selected
#emits the index, this way we don't have to reconnect the button
signal move_selected(move)

#finish up this battle
signal battle_finished()

#easy to access, onready list of our CreatureSlots
#0-maxAllies is the indicies of the allies
#maxAllies - maxAllies + maxEnemies is the indicies of the enemies
#so the index 0 enemy would be at index maxAllies 
var creatureSlots = []

var queueSlots = []

var creatureSlot = preload("./CreatureSlot.tscn")

enum States{
	SELECTING_MOVE,
	SELECTING_TARGET,
	ENEMY_TURN
}


@export var state:States = States.SELECTING_MOVE;

#change our variables based on the state of the battlefield
func setBattleState(state:Battlefield):
	if state.getCurrentCreature():
		addAttacksToUI(state.getCurrentCreature())
	for i in range(state.creatures.size()):
		addCreature(state.creatures[i],i);


func addAttacksToUI(creature:Creature):
	for i in range(Moves.size()):
		var butt = Moves[i]
		if i < creature.moves.size():
			butt.text = creature.getMove(i).getMoveName();
		elif i < Creature.maxMoves:
			#if this creature is missing a move
			#we gotta make sure it's within Creature.maxMoves because the passButton is always out of range
			butt.text = ""

#get teh creatureslot corresponding to the given creature or index
func getCreatureSlot(creature):
	if creature is Creature:
		for i in creatureSlots:
			if i.getCreature() == creature:
				return i;
	elif creature is int:
		return getCreatureSlotByIndex(creature)
	return null
	
#TODO: Can probably delete this function since the previous function is supposed to accoutn for it
func getCreatureSlotByIndex(index:int):
	if index <0 && index >= creatureSlots.size():
		return null
	return creatureSlots[index]

func removeCreature(creature:Creature):
	var index = -1;
	for i in range(creatureSlots.size()):
		if creatureSlots[i].getCreature() == creature:
			creatureSlots[i].setCreature(null)
			index = i;
	

func removeCreatureFromQueue(creature:Creature):
	for i in range(queueSlots.size() - 1,-1,-1):
		if queueSlots[i].getCreature() == creature:
			var thisSlot = queueSlots[i]
			var tween = thisSlot.getTween();
			var height = thisSlot.get_rect().size.y
			tween.parallel().tween_property(thisSlot,"position",Vector2(thisSlot.position.x,height),1)
			tween.parallel().tween_property(thisSlot.Sprite,"modulate",Color(0,0,0,-1),1)
			tween.tween_callback(func ():
				thisSlot.queue_free(); #delete the slot
				#queueSlots.pop_at(i)
				)
			queueSlots.erase(thisSlot)
			break;
		else:
			var width = queueSlots[i].get_rect().size.x
			var tween = queueSlots[i].getTween();
			tween.tween_property(queueSlots[i],"position",Vector2((i-1)*width,0),0.5)

func addCreatureToQueue(creature:Creature, index:int):
	if creature:
		var slot = creatureSlot.instantiate()

		queueSlots.insert(index,slot);
		TurnQueue.add_child(slot);
		
		var scale = TurnQueue.get_rect().size.y/slot.get_rect().size.y;
		slot.set_scale(Vector2(scale,scale));

		slot.setCreature(creature);
		
		var width = (slot.get_rect().size.x)
		for i in range(index,queueSlots.size()):
			queueSlots[i].position = Vector2((i)*width,0);
		



#toggle target choosing (flashing black and white) on/off
func choosingTargets(flash:bool,targets:Move.TARGETING_CRITERIA = Move.TARGETING_CRITERIA.ONLY_ENEMIES):
	for i in range(0,creatureSlots.size()):
		var tween = creatureSlots[i].getTween().set_loops();
		var sprite = creatureSlots[i].Sprite
		#only turn on flashing if the target is valid (an ally for an only ally move, an enemy for an only enemy move, etc)
		if sprite && flash && Move.isTargetValid(targets,true, i < Battlefield.maxAllies):
			tween.tween_property(sprite, "modulate", Color.BLACK, 1)
			tween.tween_property(sprite,"modulate",Color.WHITE,1)

		#if "flash" is false, turn off the flashing for all creatures
		else:
			sprite.set("modulate",Color.WHITE)
			tween.kill();
#func changeState(newState:States):
	#state = newState;
	#if state == States.SELECTING_MOVE:
	#else:
		#if newState == States.SELECTING_TARGET:

		

func addTarget(index:int):
	target_selected.emit(index)
			#BattleSim.handlePlayerMove(currentCreature,targets,currentMove)
		
#adds a new slot
func addSlot(isAlly:bool):
	var slot = creatureSlot.instantiate();
	var index = creatureSlots.size()
	slot.pressed.connect(func():
		addTarget(index);
			);

	slot.position = getCreaturePos(index)
	creatureSlots.push_back(slot);
	if isAlly:
		AllyRow.add_child(slot)
		slot.Sprite.set_flip_h(true);
	else:
		EnemyRow.add_child(slot)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Battlefield.maxAllies):
		addSlot(true)
	for i in range(Battlefield.maxEnemies):
		addSlot(false);
	for i in range(Moves.size()):
		Moves[i].pressed.connect(func ():
			move_selected.emit(i)
			)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#var camera = get_viewport().get_camera_2d()
	#lerp(camera.offset.x,0,1)
	#if state == States.SELECTING_TARGET:

	
#return the position for each move button based on their index		
func getMoveRect(index):
	var screenRect = get_viewport_rect();
	return Vector2(screenRect.get_center().x - screenRect.size.x/8 + screenRect.size.x/8*(index%2)
			, screenRect.end.y - screenRect.size.y/3 + screenRect.size.y/8*(index/2));
	

#index of the creature,
#-1 if not found
func getCreatureIndex(creature:Creature):
	for i in range(creatureSlots.size()):
		if creatureSlots[i].getCreature() == creature:
			return i;
	return -1

func getCreature(index:int):
	if index < 0 || index >= creatureSlots.size():
		return null
	return creatureSlots[index].getCreature()

#convert from an index to an index relative to the ally/enemy side
func convertIndex(index:int):
	return index if index < Battlefield.maxAllies else index - Battlefield.maxAllies

#return the creature's position on the screen based on its index
func getCreaturePos(index:int):
	var rect = null; #rectangle we are trying to render to
	var max = 1; #maximum number of creatures allowed in "row"
	var isAlly = index < Battlefield.maxAllies; #true if this is an ally slot
	if isAlly:
		max = Battlefield.maxAllies;
		rect = AllyRow.get_rect();
	else:
		max = Battlefield.maxEnemies;
		rect = EnemyRow.get_rect();
	
	var boolin = (1 if isAlly else 0)
	#set creature position in the battle field
	return Vector2((rect.size.x)/max*(convertIndex(index)),0)

func getCreatureGlobalPos(ind:int):
	var row = AllyRow if ind < Battlefield.maxAllies else EnemyRow
	return row.get_global_position() + (getCreaturePos(ind))

#get position of a creatureSlot
func getSlotPos(creature:Creature):
	return getCreaturePos(getCreatureIndex(creature));

func resetAllSlotPos():
	for i in range(creatureSlots.size()):
		creatureSlots[i].position = getCreaturePos(i)
		

func resetCreatureSlotPos(creature:Creature):
	getCreatureSlot(creature).position = getSlotPos(creature)

func addCreature(creature:Creature, index:int):
	if (creatureSlots[index].getCreature() != creature):
		if index < creatureSlots.size() && creatureSlots[index]:
			creatureSlots[index].setCreature(creature);

			
func setBattleText(str:String):
	BattleLog.set_text(str);

#set a move's animation
func setBattleSprite(sprite:SpriteFrames,pos:Vector2=BattleSpriteRect.get_rect().get_center()) -> void:
	BattleSprite.setSprite(sprite)

	BattleSprite.set_global_position( pos)
	BattleSprite.play();
	BattleSprite.visible = true;

func stopBattleSprite():
	if BattleSprite:
		BattleSprite.visible = false;
		

func setEndScreen(won:bool):
	EndScreen.setBattleResult(won)
	EndScreen.set_visible(true)


func _on_button_pressed():
	battle_finished.emit()
	pass # Replace with function body.
	
func reset():
	EndScreen.set_visible(false);
	for i in creatureSlots:
		i.setCreature(null)
