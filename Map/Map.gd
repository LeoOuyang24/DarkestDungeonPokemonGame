class_name GameMap extends RoomBase

@onready var Background = $Background 
var RoomScene = preload("res://Map/Room.tscn")

var rooms = [] #array of arrays that represent the columns of rooms
var routes = {} #dictionary of pairs of rooms where the first room in the pair can access the 2nd

signal room_selected(room:Room)

var currentColumn = 0 
var currentRoom = -1 #index in the column, -1 if no room selected

const maxRowSize = 6;
const minRowSize = 3;

func addRoom(room:Room, column:int, columnNum:int, rowSize:int):

	const maxRows = 5 + 1
	var vertSpacing = Background.get_rect().size.y/maxRowSize;
	var horizSpacing = Background.get_rect().size.x/maxRows;
	room.colNum = column
	room.roomNum = columnNum
	room.pressed.connect(setCurrentRoom.bind(column,columnNum))
	add_child(room)
	room.position = Vector2(100 + column*horizSpacing,
			50 + columnNum*vertSpacing + (maxRowSize - rowSize)*( vertSpacing/2) );
			

func generate():
	var rng = RandomNumberGenerator.new()
	const maxRows = 6
	for i in range(maxRows):
		var row = []
		var isFirstOrLast := i == 0 or i == maxRows - 1  #true if the room is either the first or last room
		var rowSize = rng.randi_range(minRowSize,maxRowSize) if !isFirstOrLast else 1
		for j in range(rowSize):
			var room = RoomScene.instantiate()
			addRoom(room,i,j,rowSize)
			room.setRoomType(randi()%Room.ROOM_TYPES.ROOM_TYPES_SIZE if !isFirstOrLast\
			else Room.ROOM_TYPES.BATTLE if i == 0\
			else Room.ROOM_TYPES.BOSS )
			row.push_back(room);
		if i > 0:
			var neigh:float = float(rooms[-1].size())/row.size() #how many connections per room in this row
			var leftovers:int = max(0,rooms[-1].size() - (rowSize + 1)) #how many rooms from the previous row will not have a connection
			for j in range(row.size()):
				#this complicated mess evenly divides the number of connections from the previous row among the rooms in the current row
				#there is a 50% chance of one additional connection, to add some variety
				#the last room will also connect to any rooms that don't have a connection yet

				var neighbors = max(1,ceil( neigh) + (randi()%2) + int(j == rowSize - 1)*leftovers)

				for g:int in neighbors:  
					var index = min(rooms[-1].size() - 1,g + j*max(1,floor(neigh)))
					var neighbor =rooms[-1][index]
					routes[[neighbor,row[j]]] = true
		rooms.push_back(row)

func _draw():
	const ROOM_SPACING = 20
	const DOT_SPACING = 20
	const DOT_SIZE = 5
	
	for i in routes:
		var p1 = i[0].position + i[0].size/2
		var p2 = i[1].position + i[1].size/2
		#print(i[0].get_rect(),i[1].get_rect())
		var normal = (p2 - p1).normalized()
		p1 += ROOM_SPACING*normal;
		p2 -= ROOM_SPACING*normal;
		
		var cur = p1
		while cur.x < p2.x:
			var end =  cur + (DOT_SIZE)*normal
			draw_line(cur, end,Color.WHITE,5)
			cur = end + DOT_SPACING*normal
		pass
# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	pass # Replace with function body.


#reset the map, only call this after this is already in the node tree
func reset():
	routes = {}
	for i in rooms:
		for j in i:
			remove_child(j)
			j.queue_free()
	rooms = []
	generate()
	queue_redraw()
	updateRooms()

	#setCurrentRoom(0,0)

func getCurrentRoom():
	return rooms[currentColumn][currentRoom]

#return if room nums are valid
func isValidRoomNum(colNum:int,roomNum:int):
	return colNum < rooms.size() && roomNum < rooms[colNum].size() && colNum >= 0 && roomNum >= 0

#basically make any accessible rooms accessible
func updateRooms(colNum:int = currentColumn, roomNum:int = currentRoom):
	if roomNum == -1:
		for i in rooms[0]:
			i.changeState(Room.ROOM_STATE.ACCESSIBLE)
	else:
		for column in rooms:
			for i:Room in column:
				if routes.has([rooms[colNum][roomNum],i]):
					i.changeState(Room.ROOM_STATE.ACCESSIBLE)
				elif i.getState() == Room.ROOM_STATE.ACCESSIBLE:
					i.changeState(Room.ROOM_STATE.INACCESSIBLE)
				
			
	
func getAdjacentRooms(colNum:int,roomNum:int):
	if isValidRoomNum(colNum,roomNum):
		if colNum >= rooms.size() - 1: #last column
			return []
		else:
			var arr =[]
			for i in rooms[colNum + 1]:
				if routes.get([rooms[colNum][roomNum],i]) != null:
					arr.push_back(i)
			return arr
	elif roomNum == -1: #if roomNum is -1, return the first column
		return rooms[0]
			
func setCurrentRoom(colNum:int,roomNum:int):
	if isValidRoomNum(colNum,roomNum):
		if getCurrentRoom():
			getCurrentRoom().changeState(Room.ROOM_STATE.VISITED)
		currentRoom = roomNum;
		currentColumn = colNum;
		
		getCurrentRoom().changeState(Room.ROOM_STATE.CURRENT)
		
		room_selected.emit(rooms[colNum][roomNum])

#call a function on each room
func forEachRoom(call:Callable):
	for column in rooms:
		for room in column:
			call.call(room)

#func _input(event):
	#if event is InputEventKey and event.pressed:
		#if event.keycode == KEY_R:
			#reset()
			
