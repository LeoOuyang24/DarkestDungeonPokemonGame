class_name Banshee extends Creature

static func getStartMoves() -> Array:
	return [Slash.new(),Bite.new()]

static func getPendingMoves() -> Array:
	return []

#a creature that reflects damage taken to all other allies
func _init(levels:int = 1, moves_:Array = [], pendingMoves_:Array = []) -> void:
	super("spritesheets/creatures/shapeless", 1,70,40, "???",levels,getStartMoves(),pendingMoves_)
	stats.stats[CreatureStats.STATS.HEALTH] = BansheeHealth.new(self)
	#stats.stats[]
	#GameState.PlayerState.team_changed.connect(findTarget.bind(GameState.PlayerState.getTeam()))
