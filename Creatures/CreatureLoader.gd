class_name CreatureLoader extends Object

#handles loading Creatures

static var SpriteSheetsDir = "spritesheets/creatures/"

static var CreatureJSONDir = "res://Creatures/creatures_jsons/"

static func loadMove(moveName:String) -> Move:
	return load("res://Moves/" + moveName + ".gd").new()

#load from json
static func loadJSON(file_path:String, startingLevel:int = 1) -> Creature:
	var json = JSON.new()
	var file = FileAccess.open(file_path,FileAccess.READ)
	file = FileAccess.open(CreatureJSONDir + file_path,FileAccess.READ) if !file else file #if the file couldn't be found, maybe the path was only the filename and not the absolute path
	file = FileAccess.open(CreatureJSONDir + file_path+".json",FileAccess.READ) if !file else file #if the file couldn't be found, maybe the path was only the creature name and not the filename nor abolute path
	if file:
		var error = json.parse(file.get_as_text())
		if error == OK:
			var creature = Creature.new(SpriteSheetsDir + json.data.sprite if json.data.get("sprite") else "spritesheets/creatures/invalid",
							json.data.baseHealth if json.data.get("baseHealth") else 1,
							 json.data.baseAttack if json.data.get("baseAttack") else 1,
							json.data.baseSpeed if json.data.get("baseSpeed") else 1,
							json.data.name if json.data.get("name") else "Creature",
							startingLevel,
							json.data.startMoves.map(func (moveName:String): return loadMove(moveName)) if json.data.get("startMoves") else [],
							json.data.levelMoves.map(func (moveName:String): return loadMove(moveName)) if json.data.get("levelMoves") else []
							) 
			creature.flying = json.data.flying if json.data.get("flying") != null else false
			creature.size.x = json.data.width if json.data.get("width") else 100
			creature.size.y = json.data.height if json.data.get("height") else 100
			return creature
		else:
			print("Error parsing Creature JSON, ",file_path,"\nError: ",json.get_error_message()," on line ",json.get_error_line())
	else:
		printerr("Creature JSON, " + file_path + " could not be opened!!\nError: " + error_string(FileAccess.get_open_error()));
	return null
	
static func getRandCreature():

	var dir = DirAccess.open(CreatureJSONDir)
	if dir:
		#DirAccess.make_dir_absolute("user://levels/world1")
		var jsons = dir.get_files()
		return loadJSON(CreatureJSONDir + jsons[randi()%jsons.size()])
	else:
		print("Couldn't find Creatures JSON folder!!!!")

