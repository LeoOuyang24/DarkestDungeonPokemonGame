extends Node2D

var RoomScene = preload("res://Map/Room.tscn")

var rooms = []




# Called when the node enters the scene tree for the first time.
func _ready():
	const maxRowSize = 6;
	const minRowSize = 3;
	const vertSpacing = 100;
	const horizSpacing = 100;
	var rng = RandomNumberGenerator.new()
	for i in range(5):
		var row = []
		var rowSize = rng.randi_range(minRowSize,maxRowSize)
		for j in range(rowSize):
			var room = RoomScene.instantiate();
			add_child(room)
			room.position = Vector2(100 + i*horizSpacing,
			50 + j*vertSpacing + (maxRowSize - rowSize)*( vertSpacing/2) );
			row.push_back(room);
		if i > 0:
			for j in row:
				var line = Line2D.new();
				add_child(line);
				
				line.width = 5;
				var a = j.Sprite.get_global_rect().get_center()
				var b = rooms[-1][rng.randi_range(0,rooms[-1].size() - 1)].Sprite.get_global_rect().get_center()
				line.add_point(a + 0.1*Vector2(b - a))
				line.add_point(b + 0.1*Vector2(a - b))
		rooms.push_back(row)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
