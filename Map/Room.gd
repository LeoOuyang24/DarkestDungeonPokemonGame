class_name Room extends Area2D

@onready var anime = $anime
@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D

var scene = preload("res://Map/Room.tscn")

signal new_room(room)

#represents whether or not a room has been visited
enum ROOM_STATE
{
	ACCESSIBLE, #unvisisted but accessible
	INACCESSIBLE, #unvisited and currently unreachable 
	VISITED, #has been visited
	CURRENT #is the room we are currently in
}

enum ROOM_TYPES
{
	BATTLE, #your standard fighting room
	WELL,
	COMBINE_MOVES,
	SHOP,
	ROOM_TYPES_SIZE #number of enums in this enum, should always be the last entry
}

var visited:ROOM_STATE = ROOM_STATE.INACCESSIBLE;
var roomType:ROOM_TYPES = ROOM_TYPES.BATTLE
#column and room num of the room
#basically coordinates on the map
var colNum = 0;
var roomNum = 0;

static func getRoomIcon(roomType:ROOM_TYPES):
	var spritePath = ""
	match roomType:
		ROOM_TYPES.BATTLE:
			spritePath = "res://sprites/map/enemy_room.png"
		ROOM_TYPES.WELL:
			spritePath = "res://sprites/map/well_room.png"
		ROOM_TYPES.SHOP:
			spritePath = "res://sprites/map/shop_room.png"
		ROOM_TYPES.COMBINE_MOVES:
			spritePath = "res://sprites/map/lab_moves_room.png"
		_:
			push_error("Room:getRoomIcon: roomtype did not match: ", roomType)
	var texture = load(spritePath)
	return texture

func setRoomType(roomType:ROOM_TYPES):
	self.roomType = roomType

	sprite.texture = getRoomIcon(roomType)
	#pivot_offset = texture_normal.rec
	changeState(ROOM_STATE.INACCESSIBLE)
	#pressed.connect(func():
		#new_room.emit(roomType)
		#)


func getRoomType() -> ROOM_TYPES:
	return self.roomType

func getColNum():
	return colNum

func getRoomNum():
	return roomNum

func get_rect() -> Rect2:
	return shape.get_shape().get_rect()

func getState() -> ROOM_STATE:
	return visited
	
func changeState(state:ROOM_STATE):
	visited = state;
	queue_redraw() #redraw
	if visited == ROOM_STATE.INACCESSIBLE:
		modulate = Color.DARK_GRAY
	else:
		modulate = Color.WHITE	
		
	if visited == ROOM_STATE.ACCESSIBLE:
		anime.play("accessible")
	else:
		anime.play("reset")
		
func _draw():
	var rect = get_rect()
	if visited == ROOM_STATE.CURRENT:
		draw_arc(Vector2(0,0),10,0,TAU,1000,Color.WHITE)
	elif visited == ROOM_STATE.VISITED:
		draw_line(Vector2(0,0),rect.size,Color.RED,3)
		draw_line(Vector2(0,rect.size.y),Vector2(rect.size.x,0),Color.RED,3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click") && visited == ROOM_STATE.ACCESSIBLE:
		new_room.emit(roomType)

func _input(event) -> void:
	if event is InputEventKey && event.pressed && event.keycode == KEY_BACKSPACE && visited != ROOM_STATE.VISITED:
		changeState(ROOM_STATE.ACCESSIBLE)
