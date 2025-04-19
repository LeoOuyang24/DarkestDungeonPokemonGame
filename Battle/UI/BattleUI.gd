class_name BattleUI extends Control

@onready var AllyRow = $Rows/AllyRow 
@onready var EnemyRow = $Rows/EnemyRow 
@onready var BattleSprite := $BattleSprite 
@onready var BattleLog = $BattleLog
@onready var EndScreen = $EndScreen
@onready var TurnQueue = $TurnQueue
@onready var QueueSlotOutline = %Outline
@onready var TurnUI = %TurnUI
@onready var TurnUIAnime = %TurnUI/TurnUIAnime
@onready var Summary = %CreatureSummary
@onready var PassButton = %CreatureSummary/%PassButton
@onready var History = %History
@onready var EndTurn = %EndTurn

#signal for when the ui is ready to be used
#emitted when things like containers have resized their children
signal is_ready()

#signal for when targets have been selected
signal target_selected(target)

#signal for when a move has been selected
signal move_selected(move:Move)

#signal for when a turn has been made (move and targets selected for a creature)
signal turn_made(record:Move.MoveRecord)

#finish up this battle
signal battle_finished()

#end player turn and start battle
signal end_turn()
#easy to access, onready list of our CreatureSlots
#0-maxAllies is the indicies of the allies
#maxAllies - maxAllies + maxEnemies is the indicies of the enemies
#so the index 0 enemy would be at index maxAllies 
#this array is ordered the exact same way it is in Battlefield, however, the visual positions will change
#based on what is in front and what is in the back
var creatureSlots = []

var creatureSlot = preload("./CreatureSlot.tscn")
var queueSlot = preload("./QueueSlot.tscn")

var current:Move.MoveRecord = Move.MoveRecord.new() #current creature and move
var MoveSummary:Control = null #summary of move currently being used

#multiplier of how fast we want animations
static var battleSpeed := 1.0

func newTurn(state:Battlefield):
	current = Move.MoveRecord.new()
	EndTurn.disabled = true
#	updateQueue(state.getFullQueue())
	#updateSlots(state)

	
	await get_tree().create_timer(1).timeout
	TurnUI.setText("TURN START");
	TurnUI.play();


func startBattle() -> void:
	TurnUI.setText("COMBAT START");
	TurnUI.play()
	await TurnUI.done

#add creatures to slots
func updateSlots(state:Battlefield):
	for i in range(state.creatures.size()):
		addCreature(state.creatures[i],i);
	
#reset slot appearances
func resetSlotUIs():
	for i in creatureSlots:
		i.getTween()
		i.modulate = Color.WHITE
	
#if the order of creatureslots changes, we have to reorganize "creatureSlots"
#to match the order in battlefield
func resetCreatureSlots():
	creatureSlots = AllyRow.get_children().slice(-1,0,-1) + [AllyRow.get_children()[0]] + EnemyRow.get_children()

	
func resetAllSlotPos():
	AllyRow.queue_sort()
	EnemyRow.queue_sort()

#add an outline to a queueSlot
func setQueueOutline(queueSlot:QueueSlot, color:Color) -> void:
	#adding it as a child causes it to move with the QueueSlot in the event of the queue order changing
	#this is cringe and asswipe but it works 
	if (QueueSlotOutline.get_parent()):
		QueueSlotOutline.get_parent().remove_child(QueueSlotOutline)
	queueSlot.add_child(QueueSlotOutline);
	
	QueueSlotOutline.position = Vector2(0,0)
	QueueSlotOutline.size = queueSlot.get_rect().size

	QueueSlotOutline.set_border_color(color)
	#QueueSlotOutline.visible = true;

func setCurrentCreature(creature:Creature):
	if creature:
		#apply outline to both creatureslot and the queueslot
		var slot := getCreatureSlot(creature)
		if slot:
			var rect := slot.get_global_rect()
			$ColorRect.set_size(Vector2(rect.size.x,slot.global_position.y - $Rows.global_position.y + slot.size.y));
			var tween := create_tween()
			tween.tween_property($ColorRect,"global_position",Vector2(slot.global_position.x,$Rows.global_position.y),.3*battleSpeed)
			#$ColorRect.set_global_position()
		var queueSlot := getQueueSlot(creature)
		if queueSlot:
			setQueueOutline(queueSlot,Color(0.4,0.4,0,1));

		current.user = creature
		current.move = null
		current.targets = []
		setCurrentCreatureUI(creature,true)

#sets the current creature in the summary area
func setCurrentCreatureUI(creature:Creature, isCurrent:bool):
	if creature:
		if !isCurrent:
			Resources.highlight(getCreatureSlot(creature),Color.CYAN);
		if Summary.creature && Summary.creature != current.user:
			Resources.highlight(getCreatureSlot(Summary.creature),Color(0,0,0,0));

	Summary.setCurrentCreature(creature,isCurrent)

#called when a move record has been made
func emitRecord():
	resetSlotUIs()
	turn_made.emit(current.copy())


func selectMove(move:Move):
	current.move = move
	current.targets = []

	if move:
		if move.getNumOfTargets() > current.targets.size():
			choosingTargets(move.getTargetingCriteria())
		else:
			emitRecord()
#called when the target of a move is selected
func selectTarget(creature:Creature) -> void:		
	if current.move.isTargetValid(current.move.getTargetingCriteria(),current.user,creature):
		current.targets.push_back(creatureSlots.find(getCreatureSlot(creature)))
		if current.targets.size() >= current.move.getNumOfTargets():
			emitRecord()
#called when a creature slot is pressed
func selectCreature(creature:Creature) -> void:
	if creature:
		if current.move and current.move.getNumOfTargets() > current.targets.size(): #choosing targets
			selectTarget(creature)
		else: #otherwise, chose to preview an enemy or select an ally
			if creature.getIsFriendly():
				setCurrentCreature(creature)
			else:
				#we ARE allowed to set enemy moves if we are debugging
				if DebugState.isDebugging():
					setCurrentCreature(creature)
				else:
					setCurrentCreatureUI(creature,false)

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

#swaps position of two slots
func swapSlots(slot1:CreatureSlot,slot2:CreatureSlot):
	if slot1 and slot2 and slot1.get_parent() == slot2.get_parent(): #only works if they are in the same container

		slot1.getTween().tween_property(slot1,"global_position",Vector2(slot2.global_position.x,slot1.global_position.y),0.5*battleSpeed)
		var tween = slot2.getTween().tween_property(slot2,"global_position",Vector2(slot1.global_position.x,slot2.global_position.y),0.5*battleSpeed)
		await tween.finished
		
		var row = slot1.get_parent()
		var index1 = row.get_children().find(slot1)
		var index2 = row.get_children().find(slot2)
		row.move_child(slot2,index1)
		#row.remove_child(slot1)
		row.move_child(slot1,index2)
		resetCreatureSlots()
			
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

func removeCreatureFromQueue(creature:Creature):
		var thisSlot := getQueueSlot(creature)
		if thisSlot:
			var tween = create_tween()
			var height = thisSlot.get_rect().size.y

			#tween.parallel().tween_property(thisSlot,"position",Vector2(thisSlot.position.x,height),1)
			tween.parallel().tween_property(thisSlot,"modulate",Color(0,0,0,0),1*battleSpeed)
			tween.tween_callback(func ():
				thisSlot.setCreature(null)
				)
			await tween.finished

#update the queue to match that in the MoveQueue
func updateQueue(queue:Array):
	var children = TurnQueue.get_children()
	for i in range(Battlefield.maxAllies + Battlefield.maxEnemies):
		children[i].modulate = Color(1,1,1,1)
		if i < queue.size():
			children[i].setCreature(queue[i].user)
		else:
			children[i].setCreature(null)
		
#toggle target choosing (flashing black and white) on/off
func choosingTargets(targets:Move.TARGETING_CRITERIA = Move.TARGETING_CRITERIA.ONLY_ENEMIES):
	for i in range(0,creatureSlots.size()):
		var tween = creatureSlots[i].getTween().set_loops();
		var sprite = creatureSlots[i]
		#only turn on flashing if the target is valid (an ally for an only ally move, an enemy for an only enemy move, etc)
		if sprite && Move.isTargetValid(targets,current.user,creatureSlots[i].getCreature()):
			tween.tween_property(sprite, "modulate", Color.BLACK, 1)
			tween.tween_property(sprite,"modulate",Color.WHITE,1)

#adds a new slot
func addSlot(isAlly:bool):
	var slot = creatureSlot.instantiate();
	#slot.size_flags_vertical = SIZE_SHRINK_END
	if isAlly:
		AllyRow.add_child(slot)
	else:
		EnemyRow.add_child(slot)

#show move that is currently being used
func showMove(record:Move.MoveRecord) -> void:
	var slot :=  getCreatureSlot(record.user)
	var duration := 0.5*battleSpeed
	if slot:
		var tween := create_tween()
		var control := MoveButton.getMoveTooltip(record.move,record.user)

		var userPos := slot.global_position + slot.size*0.5 - control.size*0.5
		var finalPos := Vector2(userPos.x,slot.global_position.y - control.size.y)
		control.global_position = userPos
		control.pivot_offset = control.size*0.5
		control.scale = Vector2(0.0,0.0)

		add_child(control)
		tween.parallel().tween_property(control,"global_position",finalPos,duration)
		tween.parallel().tween_property(control,"scale",Vector2(1,1),duration)

		MoveSummary = control

		await tween.finished

#undo showMove
func clearMove() -> void:
	remove_child(MoveSummary)
	MoveSummary.queue_free()
	MoveSummary = null
		
#if NOTHING is pressed, set the creature summary to our current creature
func _unhandled_input(event):
	if event is InputEventMouseButton and event.get_button_index() == MOUSE_BUTTON_LEFT:
		setCurrentCreatureUI(current.user,true)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		setCurrentCreatureUI(current.user,true)

		
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Battlefield.maxAllies):
		addSlot(true)
	for i in range(Battlefield.maxEnemies):
		addSlot(false);
	resetCreatureSlots()
	for i in range(creatureSlots.size()):
		creatureSlots[i].pressed.connect(func():
			selectCreature(creatureSlots[i].getCreature())
			);
			
	Summary.move_selected.connect(selectMove)
			
	for i in range(Battlefield.maxEnemies + Battlefield.maxAllies):
		var slot = queueSlot.instantiate()
		TurnQueue.add_child(slot);

	
	EndScreen.EndButton.pressed.connect(func():
		battle_finished.emit()
		)		
		
	await TurnQueue.sort_children
	is_ready.emit()	

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


func _on_end_turn_pressed() -> void:
	end_turn.emit()
	pass # Replace with function body.
