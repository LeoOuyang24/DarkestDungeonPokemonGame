class_name BattleUI extends Node2D

@onready var AllyRow = $AllyRow 
@onready var EnemyRow = $EnemyRow 
@onready var BattleSprite = $BattleSprite 
@onready var BattleSpriteRect = $BattleSpriteRect
@onready var BattleLog = $BattleLog
@onready var EndScreen = $EndScreen

@onready var Moves = [$Moves/Button, $Moves/Button2, $Moves/Button3, $Moves/Button4]

#signal for when targets have been selected
signal target_selected(target)

#signal for when a move has been selected
#emits the index, this way we don't have to reconnect the button
signal move_selected(move)

#easy to access, onready list of our CreatureSlots
var enemies = []
var allies = []

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
	var lambda = func (array,isAlly):
		for i in range(array.size()):
			addCreature(array[i],i,isAlly);
	
	#add allies to our slot
	lambda.call(state.allies,true)
	
	#add enemies to our slots
	lambda.call(state.enemies,false)
	


func addAttacksToUI(creature:Creature):

	for i in range(Moves.size()):
		var butt = Moves[i]
		if i < creature.moves.size():
			butt.text = creature.getMove(i).getMoveName();
		else:
			butt.text = "";

#toggle target choosing (flashing black and white) on/off
func choosingTargets(flash:bool):
	for i in enemies:
		var tween = i.getTween().set_loops();
		var sprite = i.Sprite
		if sprite && flash:
			tween.tween_property(sprite, "modulate", Color.BLACK, 1)
			tween.tween_property(sprite,"modulate",Color.WHITE,1)	
		else:
			sprite.set("modulate",Color.WHITE)
			tween.kill();
#func changeState(newState:States):
	#state = newState;
	#if state == States.SELECTING_MOVE:
	#else:
		#if newState == States.SELECTING_TARGET:

		

func addTarget(slot:CreatureSlot):
	target_selected.emit(slot.creature)
			#BattleSim.handlePlayerMove(currentCreature,targets,currentMove)
		
#adds a new slot
func addSlot(isAlly:bool):
	var slot = creatureSlot.instantiate();
	slot.pressed.connect(func():
		addTarget(slot);
			);
	var array = allies if isAlly else enemies
	slot.position = getCreaturePos(array.size(), isAlly)
	array.push_back(slot);
	if isAlly:
		AllyRow.add_child(slot)
		slot.Sprite.set_flip_h(true);
	else:
		EnemyRow.add_child(slot)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Battlefield.maxEnemies):
		addSlot(false);
		
	#REFACTOR: Change it so both allies and enemies are dynamically allocated or allocated as part of the scene
	#just be consistent!
	for i in range(Battlefield.maxAllies):
		addSlot(true)
		
	for i in range(Moves.size()):
		Moves[i].pressed.connect(func (): 
			move_selected.emit(i)
			)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if state == States.SELECTING_TARGET:

	
#return the position for each move button based on their index		
func getMoveRect(index):
	var screenRect = get_viewport_rect();
	return Vector2(screenRect.get_center().x - screenRect.size.x/8 + screenRect.size.x/8*(index%2)
			, screenRect.end.y - screenRect.size.y/3 + screenRect.size.y/8*(index/2));
	

	
#return the creature's position on the screen based on its index and whether or not its an ally
func getCreaturePos(index:int, isAlly:bool):
	var rect = null; #rectangle we are trying to render to
	var max = 1; #maximum number of creatures allowed in "row"
	if isAlly:
		max = Battlefield.maxAllies;
		rect = AllyRow.get_rect();
	else:
		max = Battlefield.maxEnemies;
		rect = EnemyRow.get_rect();
	
	var boolin = (1 if isAlly else 0)
	#set creature position in the battle field
	return Vector2(rect.size.x*boolin + rect.size.x/max*(index+boolin)*(-1 if isAlly else 1),
	0);
	
func addCreature(creature:Creature, index:int, isAlly: bool):
	var array = null;
	if isAlly:
		array = allies;
	else:
		array = enemies;
	if (array[index].creature != creature):
		if index < array.size() && array[index]:
			array[index].setCreature( creature);

			
func setBattleText(str:String):
	BattleLog.set_text(str);

#set a move's animation
func setBattleSprite(sprite:SpriteFrames) -> void:
	if BattleSprite.get_sprite_frames() != sprite:
		BattleSprite.set_sprite_frames(sprite)
		if sprite:
			var size = sprite.get_frame_texture("new_animation",0).get_size();

			BattleSprite.apply_scale( BattleSpriteRect.get_size()/size);
			BattleSprite.set_position( BattleSpriteRect.get_rect().get_center())

	BattleSprite.play();
	BattleSprite.visible = true;

func stopBattleSprite():
	if BattleSprite:
		BattleSprite.visible = false;
		
