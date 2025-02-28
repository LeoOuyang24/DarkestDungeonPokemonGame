class_name Banshee extends Creature

static func getStartMoves() -> Array:
	return [Slash.new(),Bite.new()]

static func getPendingMoves() -> Array:
	return []

#a creature that can't be killed or targeted (always counts as dead)
#so you have one additional attacker and one less healthbar
func _init(levels:int = 1, moves_:Array = [], pendingMoves_:Array = []) -> void:
	super("spritesheets/creatures/shapeless", 1,7,4, "???",levels,getStartMoves(),pendingMoves_)
	stats.stats[CreatureStats.STATS.HEALTH] = BansheeHealth.new(self)
	#stats.stats[]
	#GameState.PlayerState.team_changed.connect(findTarget.bind(GameState.PlayerState.getTeam()))
