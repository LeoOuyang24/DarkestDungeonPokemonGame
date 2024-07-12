class_name RoomInfo extends Object

#struct that represents information of a room

enum ROOM_TYPES
{
	BATTLE, #your standard fighting room
	WELL
}

#enemies
var enemies:Array = []

var roomType:ROOM_TYPES = ROOM_TYPES.BATTLE

#texture for the room icon
#i'm ngl, this should probably not be here; originally it was in the Room._ready() function
#but if you do that, you have a switch statement here, a switch there, and a switch in Game for how to 
#load the room. I aint tryna deal with 3 switches because then everytime I add a new room I gotta edit 3 files
#so we put it here so it's only 2 files
var texture:Texture2D = null 

# Called when the node enters the scene tree for the first time.
func _init(newRoomType = ROOM_TYPES.BATTLE):
	roomType = newRoomType
	var spritePath = ""
	match newRoomType:
		ROOM_TYPES.BATTLE:
			spritePath = "res://sprites/map/enemy_room.png"
			#for i in range(randi()%Battlefield.maxEnemies + 1):
				#enemies.push_back(CreatureLoader.getRandCreature())
			enemies = [CreatureLoader.loadJSON("chomper"),CreatureLoader.loadJSON("silent"),null,CreatureLoader.loadJSON("beholder")]
		ROOM_TYPES.WELL:
			spritePath = "res://sprites/map/well_icon.png"
			pass
	texture = load(spritePath)
			
func getTexture():
	return texture

func getEnemies():
	return enemies
	
func getRoomType():
	return roomType
