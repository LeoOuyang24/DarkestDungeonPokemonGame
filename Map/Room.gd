class_name Room extends TextureButton

#represents a room on the map

@onready var anime = $anime
@onready var sprite = $Sprite2D
@onready var shape = $CollisionShape2D

var scene = preload("res://Map/Room.tscn")

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
	ROOM_TYPES_SIZE, #number of enums in this enum, should always be after all random entries
	BOSS,
	
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
			spritePath = "res://sprites/map/lab_room.png"
		ROOM_TYPES.BOSS:
			spritePath="res://sprites/map/enemy_room.png"
		_:
			push_error("Room:getRoomIcon: roomtype did not match: ", roomType)
	var texture = load(spritePath)
	return texture

func setRoomType(roomType:ROOM_TYPES):
	self.roomType = roomType

	#sprite.texture = getRoomIcon(roomType)
	texture_normal = getRoomIcon(roomType)
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

func getState() -> ROOM_STATE:
	return visited
	
func changeState(state:ROOM_STATE):
	visited = state;
	queue_redraw() #redraw
	if visited == ROOM_STATE.INACCESSIBLE:
		modulate = Color.DARK_GRAY
	else:
		modulate = Color.WHITE	
	set_disabled(visited != ROOM_STATE.ACCESSIBLE)
		
	if visited == ROOM_STATE.ACCESSIBLE:
		anime.play("accessible")
	else:
		anime.play("reset")
		
func _draw():
	var rect = get_rect()
	if visited == ROOM_STATE.CURRENT:
		draw_arc(size/2,10,0,TAU,1000,Color.WHITE)
	elif visited == ROOM_STATE.VISITED:
		draw_line(Vector2(0,0),rect.size,Color.RED,3)
		draw_line(Vector2(0,rect.size.y),Vector2(rect.size.x,0),Color.RED,3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
