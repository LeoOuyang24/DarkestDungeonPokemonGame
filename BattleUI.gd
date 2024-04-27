extends Node2D

@onready var AllyRow = $AllyRow 
@onready var EnemyRow = $EnemyRow 
@onready var BattleSprite = $BattleSprite 
@onready var BattleSpriteRect = $BattleSpriteRect
@onready var BattleLog = $BattleLog

@onready var Moves = [$Moves/Button, $Moves/Button2, $Moves/Button3, $Moves/Button4]

var enemies = []
var allies = []

var creatureSlot = preload("res://CreatureSlot.tscn")

enum States{
	SELECTING_MOVE,
	SELECTING_TARGET,
	ENEMY_TURN
}

var state:States = States.SELECTING_TARGET;

func addAttacksToUI(creature:Creature):
	for i in range(len(creature.attacks)):
		var butt = Moves[i]
		butt.pressed.connect(func (): 
			print("ASDF")
			#processMove(creature,[enemies[0]],creature.attacks[i])
			)

func changeState(newState:States):
	state = newState;
	if state == States.SELECTING_MOVE:
		for i in Moves:
			i.set_visible(true);
	else:
		for i in Moves:
			i.set_visible(false);
		if newState == States.SELECTING_TARGET:
			for i in enemies:
				var tween = create_tween().set_loops();
				var sprite = i.Sprite
				if sprite:
					tween.tween_property(sprite, "modulate", Color.BLACK, 1)
					tween.tween_property(sprite,"modulate",Color.WHITE,1)
		


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(Battlefield.maxEnemies):
		var slot = creatureSlot.instantiate();
		slot.position = getCreaturePos(i,false)
		EnemyRow.add_child(slot);
		enemies.push_back(slot)
		
	#REFACTOR: Change it so both allies and enemies are dynamically allocated or allocated as part of the scene
	#just be consistent!
	for i in range(Battlefield.maxAllies):
		var slot = creatureSlot.instantiate();
		slot.position = getCreaturePos(i,true)
		AllyRow.add_child(slot);
		AllyRow.get_child(i).Sprite.flip_h = true;
		allies.push_back(AllyRow.get_child(i))
	changeState(States.SELECTING_TARGET)
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
	if index < array.size() && array[index]:
		array[index].Sprite.set_sprite_frames(creature.spriteFrame);
		array[index].Sprite.play();
		array[index].position = getCreaturePos(index,isAlly);
	
#set a move's animation
func setBattleSprite(sprite:SpriteFrames) -> void:
	if BattleSprite.get_sprite_frames() != sprite:
		BattleSprite.set_sprite_frames(sprite)
		var size = sprite.get_frame_texture("new_animation",0).get_size();

		BattleSprite.apply_scale( BattleSpriteRect.get_size()/size);
		BattleSprite.set_position( BattleSpriteRect.get_rect().get_center())

	BattleSprite.play();
	BattleSprite.visible = true;

func stopBattleSprite():
	if BattleSprite:
		BattleSprite.visible = false;
		
