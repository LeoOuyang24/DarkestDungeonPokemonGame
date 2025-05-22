class_name Creature extends Object
#A Creature is any entity with up to 4 attacks

const maxMoves = 4;
var moves:Array[MoveSlot] = []

#is the player character
var isPlayer = false

var isFriendly = false

#whether this creature needs to be rendered slightly higher becuase it flies
var flying:bool = false

var spriteFrame:SpriteFrames = null;

var scale:float = 1 #size of the creature, used purely for rendering purposes

var creatureName = "Creature"

var active := 0; #0 if creature can use moves, add 1 whenever something has a reason for it to be inactive
var inactiveReason := "" #reason for being inactive #TODO: make this show up on UI


var stats:CreatureStats = null
var level:CreatureLevel = null
var statuses:StatusManager = null
var traits:TraitManager = null

static var NullSprite := preload("res://sprites/spritesheets/creatures/nullsprite.tres")

signal move_changed(index:int,move:Move)

# "a" deals damage to "b", based on attack and defense stats. "damage" is the base damage
#returns how much damage is dealt
static func dealDamage(a:Creature,b:Creature, damage:int, type:Damage.DAMAGE_TYPES = Damage.DAMAGE_TYPES.PHYSICAL) -> int:
	if a && b:
		var before = b.stats.getCurStat(CreatureStats.STATS.HEALTH)
		var totalDamage = b.stats.takeDamage(Damage.new(damage,type))
		
		#return the actual amount of damage dealt, potentially less if the creature was overkilled
		return -1*totalDamage if b.stats.getCurStat(CreatureStats.STATS.HEALTH) >= 0 else before  
	return 0 

static var count = 0;

func _to_string() -> String:
	return "{ " + getName() + ", Health:" + str(stats.getStatObj(CreatureStats.STATS.HEALTH)) + " Attack:" + str(stats.getStatObj(CreatureStats.STATS.ATTACK)) + " Speed:" + str(stats.getStatObj(CreatureStats.STATS.SPEED)) + " }"

	
func _init( sprite:SpriteFrames, maxHealth_:int,baseAttack_:int,baseSpeed_:int, name_:String, levels:int = 1, moves_ = [], pendingMoves_:Array = []) -> void:
	spriteFrame = sprite
	if !spriteFrame:
		spriteFrame = NullSprite
	creatureName = name_;
	
	stats = CreatureStats.new(maxHealth_,baseAttack_,baseSpeed_)

	level = CreatureLevel.new(self,pendingMoves_)
	levelUp(levels - 1)
	
	statuses = StatusManager.new(self)
	traits = TraitManager.new(self)
	
	self.moves = [MoveSlot.new(),MoveSlot.new(),MoveSlot.new(),MoveSlot.new()]
	setMoves(moves_)

func duplicate() -> Creature:
	return Creature.new(spriteFrame,stats.getBaseStat(CreatureStats.STATS.HEALTH),\
	stats.getBaseStat(CreatureStats.STATS.ATTACK),\
	stats.getBaseStat(CreatureStats.STATS.SPEED),getSpeciesName(),level.getLevel(),getMoves())
	
func addBigBoost(stat:CreatureStats.STATS,num:int = 1) -> void:
	level.appliedBigBoost(num)
	#this is second so any triggers from stat_changed signal will already have the updated big boost amount
	stats.getStatObj(stat).addBigBoost(num) 

func isActive() -> bool:
	return active == 0

func addActive(a:int) -> void:
	active = max(0,active + a)

func getLevel() -> int:
	return level.getLevel()

func levelUp(amount:int =1) -> void:
	if amount > 0:
		level.levelUp(amount)
		stats.levelUp(amount)	

func isPlayerCreature():
	return isPlayer

func getSprite() -> SpriteFrames:
	return spriteFrame

func getIsFriendly():
	return isFriendly || isPlayerCreature()

func getSpeciesName():
	return creatureName

func getName():
	return traits.getAdjective() + creatureName;

func isAlive():
	return stats.getCurStat(CreatureStats.STATS.HEALTH) > 0

func newTurn() -> void:
	tickMoves()
	statuses.newTurn()
	traits.newTurn()
	
#called when acreature first enters battlefield
func firstTurn(battlefield:Battlefield) -> void:
	traits.inBattle(battlefield)

#decrease cooldown for each move
func tickMoves() -> void:
	for i in moves:
		i.decRemainingCD()
	
func setMoves(attacks_):
	var dup = attacks_.duplicate(true);
	var index:= 0;
	for move:Move in dup:
		setMove(move,index)
		index += 1

func setMove(move:Move,index:int):
	if index >= 0 and index < moves.size():
		moves[index].move = move
		move_changed.emit(index,move)

#used for dealing damage/healing
func addHealth(amount:int):
	stats.getStatObj(CreatureStats.STATS.HEALTH).modStat(amount)

	
#use the move
func useMove(move,targets):
	move.move(self,targets)
	
func getMoves() -> Array[Move]:
	var arr:Array[Move] = []
	for i in range(moves.size()):
		arr.push_back(getMove(i))
	return arr
		
	
func getMove(index) -> Move:
	if index < 0 || index >= moves.size():
		return null
	return moves[index].move;
	
func getMoveSlot(index:int) -> MoveSlot:
	if index < 0 || index >= moves.size():
		return null
	return moves[index];	
	
func getRandomMove() -> Move:
	var possible:Array[Move] = []
	for i:MoveSlot in moves:
		if i.isUsable():
			possible.push_back(i.move)
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
		var record = Move.MoveRecord.new(user,move,battlefield.getTargets(user,move))
		return record
	return null
		
