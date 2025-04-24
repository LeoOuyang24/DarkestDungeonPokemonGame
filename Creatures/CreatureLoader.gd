class_name CreatureLoader extends Object

#handles loading Creatures

static var SpriteSheetsDir = "spritesheets/creatures/"

static var CreatureJSONDir = "res://Creatures/creatures_jsons/"

static func loadMove(moveName:String) -> Move:
	#attempt to open the file first
	moveName = moveName.to_lower()
	var move := load("res://Moves/" + moveName + ".gd")
	if move:
		return move.new()
	printerr("loadMove ERROR: Could not load move " + moveName)
	return null

static func loadTrait(traitName:String) -> Trait:
	traitName = traitName.to_lower()
	var loaded := load("res://StatusEffects/Traits/" + traitName + ".gd")
	if loaded:
		return loaded.new()
	else:
		printerr("loadTrait ERROR: Could not load trait " + traitName )
		return null

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
							json.data.baseHealth if json.data.get("baseHealth") != null else 1,
							 json.data.baseAttack if json.data.get("baseAttack") != null else 1,
							json.data.baseSpeed if json.data.get("baseSpeed") != null else 1,
							json.data.name if json.data.get("name") != null else "Creature",
							startingLevel,
							json.data.startMoves.map(func (moveName:String) -> Move: return loadMove(moveName)) if json.data.get("startMoves") else [],
							json.data.levelMoves.map(func (moveName:String): return loadMove(moveName)) if json.data.get("levelMoves") else []
							) 
			creature.flying = json.data.flying if json.data.get("flying") != null else false
			if json.data.get("startPassive"):
				creature.traits.addStatus(loadTrait(json.data.startPassive))
			return creature
		else:
			printerr("Error parsing Creature JSON, ",file_path,"\nError: ",json.get_error_message()," on line ",json.get_error_line())
	else:
		printerr("Creature JSON, " + file_path + " could not be opened!!\nError: " + error_string(FileAccess.get_open_error()));
	return null
	
static func getRandCreature(bucket:Array = []) -> Creature:
	return loadJSON(bucket[randi()%bucket.size()]) if bucket.size() > 0 else null
