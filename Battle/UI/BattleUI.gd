class_name BattleUI extends Control

@onready var AllyRow = $Rows/AllyRow 
@onready var EnemyRow = $Rows/EnemyRow 
@onready var BattleSprite := $BattleSprite 
@onready var BattleLog = $BattleLog
@onready var EndScreen = $EndScreen
@onready var TurnQueue = $TurnQueue
@onready var QueueSlotOutline = %Outline

@onready var Summary = %CreatureSummary
@onready var PassButton = %CreatureSummary/%PassButton

#signal for when the ui is ready to be used
#emitted when things like containers have resized their children
signal is_ready()

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



var creatureSlot = preload("./CreatureSlot.tscn")
var queueSlot = preload("./QueueSlot.tscn")

#currentCreature
var currentCreature:Creature = null

func newTurn(state:Battlefield):
	updateQueue(state.getFullQueue())
	updateSlots(state)
	#is_ready.emit()

#add creatures to slots
func updateSlots(state:Battlefield):
	for i in range(state.creatures.size()):
		addCreature(state.creatures[i],i);

#reset slot appearances
func resetSlotUIs():
	for i in creatureSlots:
		i.getTween()
		i.modulate = Color.WHITE
	
func resetAllSlotPos():
	AllyRow.queue_sort()
	EnemyRow.queue_sort()

#add an outline to a queueSlot
func setQueueOutline(queueSlot:QueueSlot, color:Color) -> void:
	#queueSlot.add_child(QueueSlotOutline)

	QueueSlotOutline.position = queueSlot.global_position
	QueueSlotOutline.size = queueSlot.get_rect().size

	QueueSlotOutline.set_border_color(color)
	#QueueSlotOutline.visible = true;

func setCurrentCreature(creature:Creature):
	if creature:
		#remove the outlien for the previous current creature and the previously selected creature

		if currentCreature:
			var cur := getCreatureSlot(currentCreature)
			if cur:
				Resources.highlight(cur,Color(0,0,0,0))
			
		if Summary.creature:
			var cur := getCreatureSlot(Summary.creature)
			if cur:
				Resources.highlight(cur,Color(0,0,0,0))
				
		#apply outline to both creatureslot and the queueslot
		var slot := getCreatureSlot(creature)
		if slot:
			Resources.highlight(slot,Color.GOLD)
		var queueSlot := getQueueSlot(creature)
		if queueSlot:
			setQueueOutline(queueSlot,Color.GOLD);

			
		currentCreature = creature
		setCurrentCreatureUI(creature,true)

#sets the current creature in the summary area
func setCurrentCreatureUI(creature:Creature, isCurrent:bool):
	if creature:
		if !isCurrent:
			Resources.highlight(getCreatureSlot(creature),Color.CYAN);
		if Summary.creature && Summary.creature != currentCreature:
			Resources.highlight(getCreatureSlot(Summary.creature),Color(0,0,0,0));

	Summary.setCurrentCreature(creature,isCurrent)

#get teh creatureslot corresponding to the given creature or index
func getCreatureSlot(creature) -> CreatureSlot:
	if creature is Creature:
		for i in creatureSlots:
			if i.getCreature() == creature:
				return i;
	elif creature is int:
		if creature <0 && creature >= creatureSlots.size():
			return null
		return creatureSlots[creature]
	return null
	
func getQueueSlot(creature:Creature) -> QueueSlot:
	for slots in TurnQueue.get_children():
		if slots.creature == creature:
			return slots;
	return null

func addCreature(creature:Creature, index:int):
	if (creatureSlots[index].getCreature() != creature):
		if index < creatureSlots.size() && creatureSlots[index]:
			creatureSlots[index].setCreature(creature);
			if creature && creature.flying:
				#creatureSlots[index].setTransform(creatureSlots[index].getTransform().translated(Vector2(0,-50)))
				creatureSlots[index].offset_bottom = -50

func removeCreature(creature:Creature):
	if getCreatureSlot(creature):
		getCreatureSlot(creature).setCreature(null)
		await removeCreatureFromQueue(creature);
		is_ready.emit()

#remove a creature from queue because we are running its move NOT because it died
func popCreatureFromQueue(creature:Creature) -> void:
	var slot := getQueueSlot(creature);	
	var tween := create_tween()
	#tween.tween_property(slot,"modulate",Color(1,1,1,0.0),1)

func removeCreatureFromQueue(creature:Creature):
		var thisSlot := getQueueSlot(creature)
		if thisSlot:
			var tween = create_tween()
			var height = thisSlot.get_rect().size.y

			#tween.parallel().tween_property(thisSlot,"position",Vector2(thisSlot.position.x,height),1)
			tween.parallel().tween_property(thisSlot,"modulate",Color(0,0,0,0),1)
			tween.tween_callback(func ():
				thisSlot.setCreature(null)
				)
			await tween.finished
			#await TurnQueue.sort_children


func updateQueue(queue:Array):
	var children = TurnQueue.get_children()
	for i in range(Battlefield.maxAllies + Battlefield.maxEnemies):
		children[i].modulate = Color(1,1,1,1)
		if i < queue.size():
			children[i].setCreature(queue[i])
		else:
			children[i].setCreature(null)
		
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
		
#adds a new slot
func addSlot(isAlly:bool):
	var slot = creatureSlot.instantiate();
	#slot.size_flags_vertical = SIZE_SHRINK_END
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

#if NOTHING is pressed, set the creature summary to our current creature
func _unhandled_input(event):
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		setCurrentCreatureUI(currentCreature,true)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Battlefield.maxAllies):
		addSlot(true)
	for i in range(Battlefield.maxEnemies):
		addSlot(false);
	for i in range(creatureSlots.size()):
		creatureSlots[i].pressed.connect(func():
			setCurrentCreatureUI(creatureSlots[i].getCreature(),creatureSlots[i].getCreature()==currentCreature)
			target_selected.emit(i)
			);
			
	Summary.move_selected.connect(func(move):
		move_selected.emit(move)
		)
			
	for i in range(Battlefield.maxEnemies + Battlefield.maxAllies):
		var slot = queueSlot.instantiate()
		TurnQueue.add_child(slot);
	await TurnQueue.sort_children
	
	EndScreen.EndButton.pressed.connect(func():
		battle_finished.emit()
		)		

	is_ready.emit()
			
func setBattleText(str:String):
	BattleLog.set_text(str);

#set a move's animation
func setBattleSprite(sprite:SpriteFrames,pos:Vector2  ) -> void:
	if sprite:
		BattleSprite.setSprite(sprite)
		BattleSprite.set_global_position( pos - BattleSprite.get_global_rect().size*0.5)
		BattleSprite.play();
		BattleSprite.visible = true;
		await BattleSprite.looping
		stopBattleSprite()

	
func stopBattleSprite():
	if BattleSprite:
		BattleSprite.visible = false;
		
#set the end screen,
#dna is the amount of dna we won as a result of winning the battle
func setEndScreen(rewards:Rewards = null):
	EndScreen.setBattleResult(rewards)
	EndScreen.set_visible(true)

#end screen button was pressed, we done
func _on_button_pressed():
	battle_finished.emit()
	
func reset():
	EndScreen.set_visible(false);
	for i in creatureSlots:
		i.setCreature(null)
