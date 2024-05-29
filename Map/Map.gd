extends Node2D

var RoomScene = preload("res://Map/Room.tscn")

@onready var Background = $Background 

var rooms = [] #array of arrays that represent the columns of rooms
var routes = {} #dictionary of pairs of rooms where the first room in the pair can access the 2nd

signal room_selected(room)

var currentColumn = 0 
var currentRoom = -1 #index in the column, -1 if no room selected

func generate():
	const maxRowSize = 6;
	const minRowSize = 3;
	const maxRows = 5 + 1
	var vertSpacing = Background.get_rect().size.y/maxRowSize;
	var horizSpacing = Background.get_rect().size.x/maxRows;
	var rng = RandomNumberGenerator.new()
	for i in range(5):
		var row = []
		var rowSize = rng.randi_range(minRowSize,maxRowSize) if i > 0 else 1
		for j in range(rowSize):
			var room = RoomScene.instantiate();
			room.new_room.connect(func(asdf):
				processNewRoom(i,j))
			add_child(room)
			room.position = Vector2(100 + i*horizSpacing,
			50 + j*vertSpacing + (maxRowSize - rowSize)*( vertSpacing/2) );
			row.push_back(room);
		if i > 0:
			for j in row:
				var line = Line2D.new();
				add_child(line);
				
				line.width = 5;
				var a = j.get_global_rect().get_center()
				var neighbor =rooms[-1][rng.randi_range(0,rooms[-1].size() - 1)]
				var b = neighbor.get_global_rect().get_center()
				routes[[neighbor,j]] = true
				line.add_point(a + 0.1*Vector2(b - a))
				line.add_point(b + 0.1*Vector2(a - b))
		rooms.push_back(row)


# Called when the node enters the scene tree for the first time.
func _ready():
	generate()
	pass # Replace with function body.

func getCurrentRoom():
	return rooms[currentColumn][currentRoom]

#return if room nums are valid
func isValidRoomNum(colNum,roomNum):
	return colNum < rooms.size() && roomNum < rooms[colNum].size()


#process a room getting clicked
func processNewRoom(colNum,roomNum):
	if currentRoom == -1 || (getCurrentRoom().visited == Room.VISITED_STATE.CURRENT && routes.get([getCurrentRoom(),rooms[colNum][roomNum]]) != null):
		setCurrentRoom(colNum,roomNum)
	
func getAdjacentRooms(colNum,roomNum):
	if isValidRoomNum(colNum,roomNum):
		if colNum >= rooms.size() - 1: #last column
			return []
		else:
			var arr =[]																							
			for i in rooms[colNum + 1]:
				if routes.get([rooms[colNum][roomNum],i]) != null:
					arr.push_back(i)
			return arr
			
func setCurrentRoom(colNum,roomNum):
	if isValidRoomNum(colNum,roomNum):
		getCurrentRoom().changeState(Room.VISITED_STATE.VISITED)
		currentRoom = roomNum;
		currentColumn = colNum;
		
		getCurrentRoom().changeState(Room.VISITED_STATE.CURRENT)
		for i in getAdjacentRooms(colNum,roomNum):
			i.changeState(Room.VISITED_STATE.UNVISITED)
			
		room_selected.emit(rooms[colNum][roomNum])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
