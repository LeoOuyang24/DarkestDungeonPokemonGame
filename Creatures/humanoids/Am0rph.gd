class_name Am0rph extends Creature

#creature that copies the moves of the corresponding enemy, similar to Amorph

func _init(levels:int = 1, moves_:Array = [], pendingMoves_:Array = []) -> void:
	super("spritesheets/creatures/am0rph", 8,5,5, "AMORPH",levels,moves_,pendingMoves_)
	
func copyMoves(battlefield:Battlefield) -> void:
	if battlefield:
		var enemies = battlefield.getEnemies(getIsFriendly(),false)
		var allies = battlefield.getAllies(getIsFriendly(),false)
		
		#find our index
		var index = allies.find(self)
		
		#get the corresponding enemy
		#if we are too far back (3rd from the front, and there's only 2 enemies), copy the furthest back enemy
		if enemies.size() > 0:
			setMoves(enemies[min(index,enemies.size() - 1)].moves)

func firstTurn(battlefield:Battlefield) -> void:
	super(battlefield)
	copyMoves(battlefield)

func newTurn() -> void:
	super()
	copyMoves(GameState.getBattle())
			
func setMoves(attacks) -> void:
	super(attacks)
	for move:Move in moves:
		move.cooldown = 0 #this avoids emitting the signal for when a cooldown changes
