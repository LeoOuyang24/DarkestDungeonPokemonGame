class_name Am0rph extends Creature

#creature that copies the moves of the corresponding enemy, similar to Amorph

func _init(levels:int = 1, moves_:Array = [], pendingMoves_:Array = []) -> void:
	super(SpriteLoader.getSprite("spritesheets/creatures/am0rph"), 80,50,50, "Am0rph",levels,moves_,pendingMoves_)
	
#find the creature to copy and copy
func copyMoves(battlefield:Battlefield) -> void:
	if battlefield:
		var enemies = battlefield.getEnemies(getIsFriendly(),false)
		var allies = battlefield.getAllies(getIsFriendly(),false)
		
		#find our index
		var index = allies.find(self)
		
		#get the corresponding enemy
		#if we are too far back (3rd from the front, and there's only 2 enemies), copy the furthest back enemy
		if enemies.size() > 0:
			setMoves(enemies[min(index,enemies.size() - 1)].getMoves())

func firstTurn(battlefield:Battlefield) -> void:
	super(battlefield)
	copyMoves(battlefield)

func endTurn() -> void:
	super()
	copyMoves(GameState.getBattle())
