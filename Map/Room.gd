class_name Room extends TextureButton

@onready var Sprite = $Sprite;

signal new_room(room)

#represents whether or not a room has been visited
enum VISITED_STATE
{
	UNVISITED, #unvisisted
	INACCESSIBLE, #unvisited and currently unreachable 
	VISITED, #has been visited
	CURRENT #is the room we are currently in
}

var visited:VISITED_STATE = VISITED_STATE.INACCESSIBLE;

#column and room num of the room
#basically coordinates on the map
var colNum = 0;
var roomNum = 0;

var roomInfo:RoomInfo = null

# Called when the node enters the scene tree for the first time.
func _ready():
	roomInfo = RoomInfo.new()
	roomInfo.enemies = []
	for i in range(randi()%Battlefield.maxEnemies + 1):
		roomInfo.enemies.push_back(CreatureLoader.getRandCreature())
	pressed.connect(func():
		new_room.emit(self)
		)
	changeState(VISITED_STATE.INACCESSIBLE)
	pass # Replace with function body.

func getColNum():
	return colNum

func getRoomNum():
	return roomNum

func getRoomInfo():
	return roomInfo
	
func changeState(state:VISITED_STATE):
	visited = state;
	queue_redraw() #redraw
	if visited == VISITED_STATE.INACCESSIBLE:
		modulate = Color.DARK_GRAY
	else:
		modulate = Color.WHITE	
	
func _draw():

	if visited == VISITED_STATE.CURRENT:
		draw_arc(Vector2(size.x/2,size.y/2),10,0,TAU,1000,Color.WHITE)
	elif visited == VISITED_STATE.VISITED:
		draw_line(Vector2(0,0),size,Color.RED,3)
		draw_line(Vector2(0,size.y),Vector2(size.x,0),Color.RED,3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
