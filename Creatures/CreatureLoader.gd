class_name CreatureLoader extends Object

#handles loading Creatures

static var CreatureJSONDir = "res://Creatures/creatures_jsons/"

static func loadMove(moveName:String) -> Move:
	return load("res://Moves/" + moveName + ".gd").new()

#load from json
static func loadJSON(file_path:String, startingLevel:int = 1) -> Creature:
	var json = JSON.new()
	var file = FileAccess.open(file_path,FileAccess.READ)
	if file:
		var error = json.parse(file.get_as_text())
		if error == OK:
			var creature = Creature.new("spritesheets/creatures/" + json.data.sprite if json.data.get("sprite") else "spritesheets/creatures/invalid",
							json.data.baseHealth if json.data.get("baseHealth") else 1,
							 json.data.baseAttack if json.data.get("baseAttack") else 1,
							json.data.baseSpeed if json.data.get("baseSpeed") else 1,
							json.data.name if json.data.get("name") else "Creature",
							startingLevel,
							json.data.startMoves.map(func (moveName:String): return loadMove(moveName)) if json.data.get("startMoves") else [],
							json.data.levelMoves.map(func (moveName:String): return loadMove(moveName)) if json.data.get("levelMoves") else []
							) 
			creature.flying = json.data.flying if json.data.get("flying") != null else false
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

