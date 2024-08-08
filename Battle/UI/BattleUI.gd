class_name BattleUI extends Node2D

@onready var AllyRow = $Rows/AllyRow 
@onready var EnemyRow = $Rows/EnemyRow 
@onready var BattleSprite = $BattleSprite 
@onready var BattleLog = $BattleLog
@onready var EndScreen = $EndScreen
@onready var TurnQueue = $TurnQueue

@onready var Moves = [$Moves/Button, $Moves/Button2, $Moves/Button3, $Moves/Button4] 
@onready var PassButton = $Moves/PassButton


#signal for when targets have been selected
signal target_selected(target)

#signal for when a move has been selected
signal move_selected(move:Move)

#finish up this battle
signal battle_finished()

#easy to access, onready list of our CreatureSlots
#0-maxAllies is the indicies of the allies
#maxAllies - maxAllies + maxEnemies is the indicies of the enemies
#so the index 0 enemy would be at index maxAllies 
#this array is ordered the exact same way it is in Battlefield, however, the visual positions will change
#based on what is in front and what is in the back
var creatureSlots = []

#array of queue slot positions
var queueSlots = []

var creatureSlot = preload("./CreatureSlot.tscn")
var queueSlot = preload("./QueueSlot.tscn")

func newTurn(state:Battlefield):
	updateQueue(state.getFullQueue())
	updateSlots(state)

#add creatures to slots
func updateSlots(state:Battlefield):
	for i in range(state.creatures.size()):
		addCreature(state.creatures[i],i);
	#if playerTurn && state.getCurrentCreature():

#reset slot appearances
func resetSlotUIs():
	for i in creatureSlots:
		i.getTween()
		i.modulate = Color.WHITE
	
func resetAllSlotPos():
	AllyRow.queue_sort()
	EnemyRow.queue_sort()

func setCurrentCreature(creature:Creature):
	if creature:
		addAttacksToUI(creature)
		for i in range(0,Battlefield.maxAllies):
			var slot = creatureSlots[i]
			#var tween = slot.getTween()
			if slot.creature && slot.creature != creature:
				slot.modulate = Color(0.2,0.2,0.2,1)

func addAttacksToUI(creature:Creature):
	for i in range(Creature.maxMoves):
		Moves[i].setMove(creature.getMove(i) if creature else null)

#get teh creatureslot corresponding to the given creature or index
func getCreatureSlot(creature):
	if creature is Creature:
		for i in creatureSlots:
			if i.getCreature() == creature:
				return i;
	elif creature is int:
		if creature <0 && creature >= creatureSlots.size():
			return null
		return creatureSlots[creature]
	return null
	

func addCreature(creature:Creature, index:int):
	if (creatureSlots[index].getCreature() != creature):
		if index < creatureSlots.size() && creatureSlots[index]:
			creatureSlots[index].setCreature(creature);
			if creature && creature.flying:
				#creatureSlots[index].setTransform(creatureSlots[index].getTransform().translated(Vector2(0,-50)))
				creatureSlots[index].offset_bottom = -50


func removeCreatureFromQueue(creature:Creature):
	for i in range(queueSlots.size() - 1,-1,-1):
		var tween = create_tween()
		if queueSlots[i].creature == creature:
			var thisSlot = queueSlots[i]
			var height = thisSlot.get_rect().size.y
			tween.parallel().tween_property(thisSlot,"position",Vector2(thisSlot.position.x,height),1)
			tween.parallel().tween_property(thisSlot,"modulate",Color(0,0,0,0),1)
			tween.tween_callback(func ():
				thisSlot.setCreature(null)
				thisSlot.modulate = Color(1,1,1,1)
				)
			break;

func updateQueue(queue:Array):
	for i in range(queueSlots.size()):
		if i < queue.size():
			queueSlots[i].setCreature(queue[i])
		else:
			queueSlots[i].setCreature(null)
		
#toggle target choosing (flashing black and white) on/off
func choosingTargets(targets:Move.TARGETING_CRITERIA = Move.TARGETING_CRITERIA.ONLY_ENEMIES):
	for i in range(0,creatureSlots.size()):
		var tween = creatureSlots[i].getTween().set_loops();
		var sprite = creatureSlots[i]
		#only turn on flashing if the target is valid (an ally for an only ally move, an enemy for an only enemy move, etc)
		if sprite && Move.isTargetValid(targets,true, i < Battlefield.maxAllies):
			tween.tween_property(sprite, "modulate", Color.BLACK, 1)
			tween.tween_property(sprite,"modulate",Color.WHITE,1)
		##if "flash" is false, turn off the flashing for all creatures
		#else:
			#sprite.set("modulate",Color.WHITE)
			#tween.kill();

		

func addTarget(index:int):
	target_selected.emit(index)
		
#adds a new slot
func addSlot(isAlly:bool):
	var slot = creatureSlot.instantiate();
	if isAlly:
		#due to how the creature slots are set up in an Hbox, (lower index = further to the left)
		#we have to flip the index if the creature is friendly. So we insert in the beginnign
		#rather than the end. This makes it so that the newly created slot is the new front-most (right-most)
		#slot with a 0 index.
		creatureSlots.insert(0,slot);
		AllyRow.add_child(slot)
	else:
		creatureSlots.push_back(slot)
		EnemyRow.add_child(slot)

	

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Battlefield.maxAllies):
		addSlot(true)
	for i in range(Battlefield.maxEnemies):
		addSlot(false);
	for i in range(creatureSlots.size()):
		creatureSlots[i].pressed.connect(func():
			addTarget(i);
			);
	for i in range(Battlefield.maxEnemies + Battlefield.maxAllies):
		var slot = queueSlot.instantiate()
		TurnQueue.add_child(slot);
		queueSlots.push_back(slot)
	
	PassButton.setMove(PassTurn.new())
	PassButton.move_selected.connect(func (move):
		move_selected.emit(move)
		)
	
	EndScreen.EndButton.pressed.connect(func():
		battle_finished.emit()
		)		

			
func setBattleText(str:String):
	BattleLog.set_text(str);

#set a move's animation
func setBattleSprite(sprite:SpriteFrames,pos:Vector2  ) -> void:
	if sprite:
		BattleSprite.setSprite(sprite)
		BattleSprite.set_global_position( pos - BattleSprite.get_global_rect().size*0.5)
		BattleSprite.play();
		BattleSprite.visible = true;

	
func stopBattleSprite():
	if BattleSprite:
		BattleSprite.visible = false;
		
#set the end screen,
#dna is the amount of dna we won as a result of winning the battle
func setEndScreen(won:bool,rewards:Rewards = null):
	EndScreen.setBattleResult(won,rewards)
	EndScreen.set_visible(true)

#end screen button was pressed, we done
func _on_button_pressed():
	battle_finished.emit()
	
func reset():
	EndScreen.set_visible(false);
	for i in creatureSlots:
		i.setCreature(null)


func _on_button_move_selected(move:Move):
	move_selected.emit(move)
	pass # Replace with function body.
