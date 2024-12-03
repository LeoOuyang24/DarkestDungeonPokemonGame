class_name Creature extends Object
#A Creature is any entity with up to 4 attacks

const maxMoves = 4;
var moves = []

#is the player character
var isPlayer = false

var isFriendly = false

#whether this creature needs to be rendered slightly higher becuase it flies
var flying:bool = false

var spriteFrame:SpriteFrames = null;

var size:Vector2 = Vector2(100,100) #size of the creature, used purely for rendering purposes

var creatureName = "Creature"


var stats:CreatureStats = null
var level:CreatureLevel = null
var statuses:StatusManager = null
var traits:TraitManager = null

# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
static func dealDamage(a:Creature,b:Creature, damage):
	if a && b:
		b.addHealth(b.stats.damageMods.getValue(-damage)); 

static var count = 0;

func _to_string() -> String:
	return "{ " + getName() + ", Health:" + str(stats.getStatObj(CreatureStats.STATS.HEALTH)) + " Attack:" + str(stats.getStatObj(CreatureStats.STATS.ATTACK)) + " Speed:" + str(stats.getStatObj(CreatureStats.STATS.SPEED)) + " }"

func _init( sprite_path:String, maxHealth_:int,baseAttack_:int,baseSpeed_:int, name_:String, levels:int = 1, moves_:Array = [], pendingMoves_:Array = []) -> void:
	spriteFrame = SpriteLoader.getSprite(sprite_path)
	creatureName = name_;
	
	#TODO: level up stats, currently they are stuck at level 1 regardless of what level we put into the constructor
	stats = CreatureStats.new(maxHealth_,baseAttack_,baseSpeed_)

	level = CreatureLevel.new(pendingMoves_)
	
	statuses = StatusManager.new(self)
	traits = TraitManager.new(self)
	
	setMoves(moves_)
	

func getLevel() -> int:
	return level.getLevel()

func levelUp() -> void:
	level.levelUp()
	stats.levelUp()	

func isPlayerCreature():
	return isPlayer

func getSprite() -> SpriteFrames:
	return spriteFrame

func getIsFriendly():
	return isFriendly || isPlayerCreature()

func getName():
	return traits.getAdjective() + creatureName;

func isAlive():
	return stats.getCurStat(CreatureStats.STATS.HEALTH) > 0

func newTurn() -> void:
	tickMoves()
	statuses.newTurn()
	traits.newTurn()

#decrease cooldown for each move
func tickMoves() -> void:
	for i in moves:
		i.decRemainingCD()
	
func setMoves(attacks_):
	moves = attacks_.slice(0,min(maxMoves,len(attacks_)),1,true); #deep copy the first 4 attacks, or fewer if fewer were provided

#used for dealing damage/healing
func addHealth(amount:int):
	stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(amount)

	
#use the move
func useMove(move,targets):
	move.move(self,targets)
	
func getMove(index):
	if index < 0 || index >= moves.size():
		return null
	return moves[index];
func getRandomMove():
	return moves[randi()%moves.size()]
	
func addTrait(t:Trait):
	traits.addStatus(t)

#given a creature, its allies, and its targets,
#run the AI for the creature
#return the move it would use
static func AI(user,allies,enemies) -> Move.MoveRecord:
	if len(user.moves) > 0 and len(enemies) > 0:
		var move = user.getRandomMove()
		var targets = []
		var targetingCriteria = move.getTargetingCriteria()
		for i in move.getNumOfTargets():
			var targetArray = null
			if targetingCriteria == Move.TARGETING_CRITERIA.ONLY_ENEMIES:
				targetArray = enemies
			elif targetingCriteria == Move.TARGETING_CRITERIA.ONLY_ALLIES:
				targetArray = allies
			elif targetingCriteria == Move.TARGETING_CRITERIA.ALLIES_AND_ENEMIES:
				targetArray = allies + enemies
			var chosen = -1
			while (chosen == -1 || targetArray[chosen] == null || targets.find(chosen) != -1) && targets.size()< targetArray.size():
				chosen = randi()%targetArray.size()
			targets.push_back(chosen)
		return Move.MoveRecord.new(user,move,targets)
	return null
		#user.attacks[randi()%len(user.attacks)].move(user,[targets[0]])
		
