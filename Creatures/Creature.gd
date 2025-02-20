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

signal move_changed(index:int,move:Move)

# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
#returns how much damage is dealt
static func dealDamage(a:Creature,b:Creature, damage:int) -> int:
	if a && b:
		var totalDamage = b.stats.damageMods.getValue(-damage)
		var before = b.stats.getCurStat(CreatureStats.STATS.HEALTH)
		b.addHealth(totalDamage);
		#return the actual amount of damage dealt, potentially less if the creature was overkilled
		return -1*totalDamage if b.stats.getCurStat(CreatureStats.STATS.HEALTH) >= 0 else before 
	return 0 

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
	
func addBigBoost(stat:CreatureStats.STATS,num:int = 1) -> void:
	level.appliedBigBoost(num)
	#this is second so any triggers from stat_changed signal will already have the updated big boost amount
	stats.getStatObj(stat).addBigBoost(num) 

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

func setMove(move:Move,index:int):
	if index >= 0 and index < maxMoves:
		if index >= moves.size():
			moves.push_back(move)
			move_changed.emit(moves.size()-1,move)

		else:
			moves[index] = move
			move_changed.emit(index,move)

#used for dealing damage/healing
func addHealth(amount:int):
	stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(amount)

	
#use the move
func useMove(move,targets):
	move.move(self,targets)
	
func getMove(index) -> Move:
	if index < 0 || index >= moves.size():
		return null
	return moves[index];
func getRandomMove() -> Move:
	var possible:Array[Move] = []
	for i:Move in moves:
		if i.isUsable():
			possible.push_back(i)
	if possible.size() == 0:
		return PassTurn.new()
	return possible[randi()%possible.size()]
	
func addTrait(t:Trait):
	traits.addStatus(t)

#given a creature and the current battlefield
#run the AI for the creature
#return the move it would use
static func AI(user:Creature, battlefield:Battlefield) -> Move.MoveRecord:
	if user:
		var move = user.getRandomMove()
		return Move.MoveRecord.new(user,move,battlefield.getTargets(user,move))
	return null
		#user.attacks[randi()%len(user.attacks)].move(user,[targets[0]])
		
