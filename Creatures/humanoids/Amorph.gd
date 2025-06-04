class_name Amorph extends Creature

#a special creature that copies the corresponding enemy's attack and speed

func _init(levels:int = 1, moves_:Array = [], pendingMoves_:Array = []) -> void:
	super(SpriteLoader.getSprite("spritesheets/creatures/AMORPH"), 200,1,1, "AMORPH",levels,\
	[Chomp.new(),Slash.new()],pendingMoves_)
	stats = AmorphStats.new(20,1,1)
	stats.owner = self
	
	
